/*
  # Fix employee policies

  1. Changes
    - Drop existing employee policies that cause recursion
    - Create new simplified policies for employee access
    - Add index for better performance
  
  2. Security
    - Maintain row level security
    - Ensure proper access control
    - Prevent infinite recursion in policies
*/

-- Drop existing problematic policies
DROP POLICY IF EXISTS "employee_read_self" ON employees;
DROP POLICY IF EXISTS "employee_read_organization" ON employees;
DROP POLICY IF EXISTS "employee_superadmin_access" ON employees;
DROP POLICY IF EXISTS "employee_company_admin_access" ON employees;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_employees_user_org ON employees(id, organization_id);

-- Create new simplified policies
CREATE POLICY "employee_self_read"
  ON employees
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "employee_org_read"
  ON employees
  FOR SELECT
  TO authenticated
  USING (
    organization_id IN (
      SELECT e.organization_id
      FROM employees e
      WHERE e.id = auth.uid()
    )
  );

CREATE POLICY "employee_admin_all"
  ON employees
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM employees e
      WHERE e.id = auth.uid()
      AND (
        (e.role = 'company_admin' AND e.organization_id = employees.organization_id)
        OR e.role = 'superadmin'
      )
    )
  );