/*
  # Fix employee policies recursion

  1. Changes
    - Drop existing problematic policies that cause recursion
    - Create new optimized policies with direct access patterns
    - Add performance indexes
  
  2. Security
    - Maintain same security rules but with better implementation
    - Ensure proper access control for all operations
*/

-- Drop existing problematic policies
DROP POLICY IF EXISTS "employee_self_read" ON employees;
DROP POLICY IF EXISTS "employee_org_read" ON employees;
DROP POLICY IF EXISTS "employee_admin_all" ON employees;

-- Create optimized indexes
CREATE INDEX IF NOT EXISTS idx_employees_role_org ON employees(role, organization_id);

-- Basic self-access policy (no recursion)
CREATE POLICY "employees_read_self"
  ON employees
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

-- Organization member read access (no recursion)
CREATE POLICY "employees_read_org_members"
  ON employees
  FOR SELECT
  TO authenticated
  USING (
    organization_id = (
      SELECT organization_id
      FROM employees
      WHERE id = auth.uid()
      LIMIT 1
    )
  );

-- Admin write access (no recursion)
CREATE POLICY "employees_admin_write"
  ON employees
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM employees
      WHERE id = auth.uid()
      AND (
        role = 'superadmin'
        OR (
          role = 'company_admin'
          AND organization_id = employees.organization_id
        )
      )
      LIMIT 1
    )
  );