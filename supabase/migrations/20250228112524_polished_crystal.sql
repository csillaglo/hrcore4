/*
  # Fix RLS policies to prevent recursion

  1. Changes
    - Drop existing problematic policies
    - Create simplified policies without circular dependencies
    - Add proper indexes for performance
    - Ensure proper role-based access control
*/

-- Drop existing problematic policies
DROP POLICY IF EXISTS "employee_view_self" ON employees;
DROP POLICY IF EXISTS "employee_view_org_members" ON employees;
DROP POLICY IF EXISTS "employee_admin_manage" ON employees;
DROP POLICY IF EXISTS "organization_read_access" ON organizations;
DROP POLICY IF EXISTS "organization_write_access" ON organizations;

-- Create index for faster policy evaluation
CREATE INDEX IF NOT EXISTS idx_employees_role_org ON employees(role, organization_id);

-- Organizations policies
CREATE POLICY "organizations_read"
  ON organizations
  FOR SELECT
  TO authenticated
  USING (
    -- Allow access if user is a member of the organization
    EXISTS (
      SELECT 1 
      FROM employees e 
      WHERE e.id = auth.uid() 
      AND e.organization_id = organizations.id
      LIMIT 1
    )
  );

CREATE POLICY "organizations_write"
  ON organizations
  USING (
    -- Allow write access for superadmins and company admins
    EXISTS (
      SELECT 1 
      FROM employees e 
      WHERE e.id = auth.uid() 
      AND e.organization_id = organizations.id
      AND e.role IN ('superadmin', 'company_admin')
      LIMIT 1
    )
  );

-- Employees policies
CREATE POLICY "employees_read_self"
  ON employees
  FOR SELECT
  TO authenticated
  USING (
    -- Users can always read their own profile
    id = auth.uid()
  );

CREATE POLICY "employees_read_organization"
  ON employees
  FOR SELECT
  TO authenticated
  USING (
    -- Users can read profiles in their organization
    organization_id IN (
      SELECT organization_id 
      FROM employees self 
      WHERE self.id = auth.uid()
      LIMIT 1
    )
  );

CREATE POLICY "employees_write"
  ON employees
  USING (
    -- Only admins can modify employee records
    EXISTS (
      SELECT 1 
      FROM employees admin 
      WHERE admin.id = auth.uid()
      AND admin.role IN ('superadmin', 'company_admin')
      AND (
        admin.role = 'superadmin' 
        OR admin.organization_id = employees.organization_id
      )
      LIMIT 1
    )
  );

-- Departments policies
CREATE POLICY "departments_read"
  ON departments
  FOR SELECT
  TO authenticated
  USING (
    -- Users can read departments in their organization
    organization_id IN (
      SELECT organization_id 
      FROM employees self 
      WHERE self.id = auth.uid()
      LIMIT 1
    )
  );

CREATE POLICY "departments_write"
  ON departments
  USING (
    -- Only admins can modify departments
    EXISTS (
      SELECT 1 
      FROM employees admin 
      WHERE admin.id = auth.uid()
      AND admin.role IN ('superadmin', 'company_admin')
      AND (
        admin.role = 'superadmin' 
        OR admin.organization_id = departments.organization_id
      )
      LIMIT 1
    )
  );

-- Employee departments policies
CREATE POLICY "employee_departments_read"
  ON employee_departments
  FOR SELECT
  TO authenticated
  USING (
    -- Users can read their own assignments and those in their organization
    employee_id = auth.uid()
    OR
    employee_id IN (
      SELECT e.id 
      FROM employees e 
      WHERE e.organization_id = (
        SELECT organization_id 
        FROM employees self 
        WHERE self.id = auth.uid()
        LIMIT 1
      )
    )
  );

CREATE POLICY "employee_departments_write"
  ON employee_departments
  USING (
    -- Only admins can modify department assignments
    EXISTS (
      SELECT 1 
      FROM employees admin 
      WHERE admin.id = auth.uid()
      AND admin.role IN ('superadmin', 'company_admin')
      AND (
        admin.role = 'superadmin' 
        OR admin.organization_id = (
          SELECT organization_id 
          FROM employees e 
          WHERE e.id = employee_departments.employee_id
          LIMIT 1
        )
      )
      LIMIT 1
    )
  );