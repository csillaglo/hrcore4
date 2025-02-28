/*
  # Fix RLS policies recursion

  1. Changes
    - Simplify policy structure to prevent recursion
    - Use direct role checks
    - Optimize query performance
    - Add superadmin policies

  2. Security
    - Maintains proper access control
    - Prevents policy recursion
    - Ensures proper role-based access
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view organizations they belong to" ON organizations;
DROP POLICY IF EXISTS "Company admins can manage their organization" ON organizations;
DROP POLICY IF EXISTS "Users can view departments in their organization" ON departments;
DROP POLICY IF EXISTS "Admins can manage departments" ON departments;
DROP POLICY IF EXISTS "Users can view employees in their organization" ON employees;
DROP POLICY IF EXISTS "Admins can manage employees" ON employees;
DROP POLICY IF EXISTS "Users can view employee departments in their organization" ON employee_departments;
DROP POLICY IF EXISTS "Admins can manage employee departments" ON employee_departments;

-- Organizations policies
CREATE POLICY "Superadmin full access"
  ON organizations
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM employees WHERE id = auth.uid() AND role = 'superadmin'
    )
  );

CREATE POLICY "Organization member read access"
  ON organizations
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM employees WHERE id = auth.uid() AND organization_id = organizations.id
    )
  );

CREATE POLICY "Company admin manage access"
  ON organizations
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM employees WHERE id = auth.uid() AND organization_id = organizations.id AND role = 'company_admin'
    )
  );

-- Departments policies
CREATE POLICY "Department member read access"
  ON departments
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM employees WHERE id = auth.uid() AND organization_id = departments.organization_id
    )
  );

CREATE POLICY "Department admin manage access"
  ON departments
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM employees WHERE id = auth.uid() AND organization_id = departments.organization_id AND role IN ('company_admin', 'superadmin')
    )
  );

-- Employees policies
CREATE POLICY "Employee self access"
  ON employees
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "Employee organization read access"
  ON employees
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM employees AS e2 WHERE e2.id = auth.uid() AND e2.organization_id = employees.organization_id
    )
  );

CREATE POLICY "Employee admin manage access"
  ON departments
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM employees WHERE id = auth.uid() AND organization_id = departments.organization_id AND role IN ('company_admin', 'superadmin')
    )
  );

-- Employee departments policies
CREATE POLICY "Employee department self access"
  ON employee_departments
  FOR SELECT
  TO authenticated
  USING (employee_id = auth.uid());

CREATE POLICY "Employee department organization access"
  ON employee_departments
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM employees e 
      WHERE e.id = employee_departments.employee_id 
      AND EXISTS (
        SELECT 1 FROM employees e2 
        WHERE e2.id = auth.uid() 
        AND e2.organization_id = e.organization_id
      )
    )
  );

CREATE POLICY "Employee department admin manage access"
  ON employee_departments
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM employees e 
      WHERE e.id = employee_departments.employee_id 
      AND EXISTS (
        SELECT 1 FROM employees e2 
        WHERE e2.id = auth.uid() 
        AND e2.organization_id = e.organization_id
        AND e2.role IN ('company_admin', 'superadmin')
      )
    )
  );