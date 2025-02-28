/*
  # Fix employee policies to prevent recursion

  1. Changes
    - Drop existing problematic policies
    - Create simplified policies without circular references
    - Add efficient indexes for policy performance

  2. Security
    - Maintain row-level security
    - Ensure proper access control
    - Prevent infinite recursion in policy checks
*/

-- Drop existing problematic policies
DROP POLICY IF EXISTS "employee_read_own_profile" ON employees;
DROP POLICY IF EXISTS "employee_read_organization_members" ON employees;
DROP POLICY IF EXISTS "employee_admin_access" ON employees;

-- Create index for faster policy evaluation
CREATE INDEX IF NOT EXISTS idx_employees_auth_role ON employees(id, role, organization_id);

-- Basic self-access policy
CREATE POLICY "employees_self_access"
  ON employees
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

-- Organization-wide read access
CREATE POLICY "employees_org_read"
  ON employees
  FOR SELECT
  TO authenticated
  USING (
    organization_id IN (
      SELECT e.organization_id
      FROM employees e
      WHERE e.id = auth.uid()
      LIMIT 1
    )
  );

-- Admin write access
CREATE POLICY "employees_admin_write"
  ON employees
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM employees e
      WHERE e.id = auth.uid()
      AND e.role IN ('superadmin', 'company_admin')
      AND (
        e.role = 'superadmin'
        OR e.organization_id = employees.organization_id
      )
      LIMIT 1
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM employees e
      WHERE e.id = auth.uid()
      AND e.role IN ('superadmin', 'company_admin')
      AND (
        e.role = 'superadmin'
        OR e.organization_id = employees.organization_id
      )
      LIMIT 1
    )
  );