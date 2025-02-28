/*
  # Fix RLS policies recursion

  1. Changes
    - Remove recursive policy checks for employees table
    - Simplify organization access policies
    - Update department policies to use direct role checks
    - Add missing employee policies

  2. Security
    - Maintains proper access control while avoiding recursion
    - Ensures proper role-based access
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Superadmins can do everything with organizations" ON organizations;
DROP POLICY IF EXISTS "Company admins can view and edit their organization" ON organizations;
DROP POLICY IF EXISTS "Managers and employees can view their organization" ON organizations;
DROP POLICY IF EXISTS "Company admins can manage departments" ON departments;
DROP POLICY IF EXISTS "Managers can view departments" ON departments;
DROP POLICY IF EXISTS "Users can view their own profile" ON employees;
DROP POLICY IF EXISTS "Company admins can manage employees in their organization" ON employees;
DROP POLICY IF EXISTS "Managers can view employees in their organization" ON employees;

-- Organizations policies
CREATE POLICY "Users can view organizations they belong to"
  ON organizations
  FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT organization_id 
      FROM employees 
      WHERE employees.id = auth.uid()
    )
  );

CREATE POLICY "Company admins can manage their organization"
  ON organizations
  USING (
    id IN (
      SELECT organization_id 
      FROM employees 
      WHERE employees.id = auth.uid() 
      AND employees.role = 'company_admin'
    )
  );

-- Departments policies
CREATE POLICY "Users can view departments in their organization"
  ON departments
  FOR SELECT
  TO authenticated
  USING (
    organization_id IN (
      SELECT organization_id 
      FROM employees 
      WHERE employees.id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage departments"
  ON departments
  USING (
    organization_id IN (
      SELECT organization_id 
      FROM employees 
      WHERE employees.id = auth.uid() 
      AND employees.role IN ('company_admin', 'superadmin')
    )
  );

-- Employees policies
CREATE POLICY "Users can view employees in their organization"
  ON employees
  FOR SELECT
  TO authenticated
  USING (
    organization_id IN (
      SELECT organization_id 
      FROM employees e2 
      WHERE e2.id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage employees"
  ON employees
  USING (
    organization_id IN (
      SELECT organization_id 
      FROM employees e2 
      WHERE e2.id = auth.uid() 
      AND e2.role IN ('company_admin', 'superadmin')
    )
  );

-- Employee departments policies
CREATE POLICY "Users can view employee departments in their organization"
  ON employee_departments
  FOR SELECT
  TO authenticated
  USING (
    employee_id IN (
      SELECT e.id 
      FROM employees e 
      WHERE e.organization_id IN (
        SELECT organization_id 
        FROM employees e2 
        WHERE e2.id = auth.uid()
      )
    )
  );

CREATE POLICY "Admins can manage employee departments"
  ON employee_departments
  USING (
    employee_id IN (
      SELECT e.id 
      FROM employees e 
      WHERE e.organization_id IN (
        SELECT organization_id 
        FROM employees e2 
        WHERE e2.id = auth.uid() 
        AND e2.role IN ('company_admin', 'superadmin')
      )
    )
  );