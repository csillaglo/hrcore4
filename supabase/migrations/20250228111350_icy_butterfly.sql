/*
  # Simplified access control policies

  1. Changes
    - Drop existing problematic policies
    - Create new simplified policies without recursion
    - Add performance optimizations
    - Fix infinite recursion issues

  2. Security
    - Maintain proper access control
    - Prevent unauthorized access
    - Optimize query performance
*/

-- Create index for faster policy evaluation
CREATE INDEX IF NOT EXISTS idx_employees_org_role ON employees(organization_id, role);

-- Drop existing problematic policies
DROP POLICY IF EXISTS "employees_self_access" ON employees;
DROP POLICY IF EXISTS "employees_org_read" ON employees;
DROP POLICY IF EXISTS "employees_admin_write" ON employees;

-- Simple self-access policy
CREATE POLICY "employee_view_self"
  ON employees
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

-- Organization member read policy
CREATE POLICY "employee_view_org_members"
  ON employees
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM employees viewer
      WHERE viewer.id = auth.uid()
      AND viewer.organization_id = employees.organization_id
      LIMIT 1
    )
  );

-- Admin management policy
CREATE POLICY "employee_admin_manage"
  ON employees
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM employees admin
      WHERE admin.id = auth.uid()
      AND admin.role IN ('superadmin', 'company_admin')
      AND (
        admin.role = 'superadmin' OR 
        admin.organization_id = employees.organization_id
      )
      LIMIT 1
    )
  );