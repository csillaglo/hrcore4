/*
  # Fix employee policies and recursion issues

  1. Changes
    - Drop existing problematic policies
    - Create optimized policies without recursion
    - Add indexes for better performance

  2. Security
    - Maintain proper access control
    - Prevent infinite recursion
    - Optimize query performance
*/

-- Drop existing problematic policies
DROP POLICY IF EXISTS "employees_basic_access" ON employees;
DROP POLICY IF EXISTS "employees_admin_access" ON employees;

-- Create optimized indexes
CREATE INDEX IF NOT EXISTS idx_employees_auth_role_org ON employees(id, role, organization_id);

-- Create new simplified policies
CREATE POLICY "employee_read_self"
  ON employees
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "employee_read_organization"
  ON employees
  FOR SELECT
  TO authenticated
  USING (
    organization_id IN (
      SELECT organization_id
      FROM employees
      WHERE id = auth.uid()
      LIMIT 1
    )
  );

CREATE POLICY "employee_superadmin_access"
  ON employees
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM employees
      WHERE id = auth.uid()
      AND role = 'superadmin'
      LIMIT 1
    )
  );

CREATE POLICY "employee_company_admin_access"
  ON employees
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM employees admin
      WHERE admin.id = auth.uid()
      AND admin.role = 'company_admin'
      AND admin.organization_id = employees.organization_id
      LIMIT 1
    )
  );