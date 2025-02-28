/*
  # Add sample data with auth users

  1. New Data
    - 2 organizations
    - 5 departments per organization
    - Auth users and employees created properly
    - 1 admin per organization
    - 4 employees per department

  2. Structure
    - Creates auth users first
    - Links employees to auth users
    - Maintains proper relationships
*/

-- Create sample organizations
INSERT INTO organizations (id, name, website, address, is_active) VALUES
  ('11111111-1111-1111-1111-111111111111', 'TechCorp Solutions', 'https://techcorp.example.com', 'Budapest, Hungary', true),
  ('22222222-2222-2222-2222-222222222222', 'InnoTech Systems', 'https://innotech.example.com', 'Debrecen, Hungary', true);

-- Create departments for TechCorp Solutions
INSERT INTO departments (id, organization_id, name, description, is_active) VALUES
  ('d1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Software Development', 'Core software development team', true),
  ('d1111111-1111-1111-1111-111111111112', '11111111-1111-1111-1111-111111111111', 'Quality Assurance', 'Software testing and quality control', true),
  ('d1111111-1111-1111-1111-111111111113', '11111111-1111-1111-1111-111111111111', 'DevOps', 'Infrastructure and deployment', true),
  ('d1111111-1111-1111-1111-111111111114', '11111111-1111-1111-1111-111111111111', 'Product Design', 'UI/UX and product design', true),
  ('d1111111-1111-1111-1111-111111111115', '11111111-1111-1111-1111-111111111111', 'Customer Support', 'Technical support and customer service', true);

-- Create departments for InnoTech Systems
INSERT INTO departments (id, organization_id, name, description, is_active) VALUES
  ('d2222222-2222-2222-2222-222222222221', '22222222-2222-2222-2222-222222222222', 'Research & Development', 'Innovation and research team', true),
  ('d2222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'Data Science', 'AI and machine learning', true),
  ('d2222222-2222-2222-2222-222222222223', '22222222-2222-2222-2222-222222222222', 'Cloud Services', 'Cloud infrastructure and services', true),
  ('d2222222-2222-2222-2222-222222222224', '22222222-2222-2222-2222-222222222222', 'Security', 'Information security and compliance', true),
  ('d2222222-2222-2222-2222-222222222225', '22222222-2222-2222-2222-222222222222', 'Mobile Development', 'Mobile apps and solutions', true);

-- Function to create an auth user and employee
CREATE OR REPLACE FUNCTION create_user_and_employee(
  p_email TEXT,
  p_first_name TEXT,
  p_last_name TEXT,
  p_organization_id UUID,
  p_department_id UUID DEFAULT NULL,
  p_role TEXT DEFAULT 'employee',
  p_phone TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Create auth user
  v_user_id := gen_random_uuid();
  
  INSERT INTO auth.users (
    id,
    email,
    email_confirmed_at,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change_token_current,
    email_change_token_new,
    recovery_token
  ) VALUES (
    v_user_id,
    p_email,
    now(),
    jsonb_build_object(
      'first_name', p_first_name,
      'last_name', p_last_name
    ),
    now(),
    now(),
    '',
    '',
    '',
    ''
  );

  -- Create employee record
  INSERT INTO employees (
    id,
    organization_id,
    department_id,
    first_name,
    last_name,
    email,
    role,
    phone,
    is_active
  ) VALUES (
    v_user_id,
    p_organization_id,
    p_department_id,
    p_first_name,
    p_last_name,
    p_email,
    p_role,
    p_phone,
    true
  );

  RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;

-- Create employees for TechCorp Solutions
DO $$
DECLARE
  dept_id uuid;
  org_id uuid := '11111111-1111-1111-1111-111111111111';
  emp_id uuid;
  i int;
BEGIN
  -- Create company admin
  PERFORM create_user_and_employee(
    'janos.nagy@techcorp.example.com',
    'János',
    'Nagy',
    org_id,
    NULL,
    'company_admin',
    '+36201234567'
  );

  -- Create department employees
  FOR dept_id IN 
    SELECT id FROM departments WHERE organization_id = org_id
  LOOP
    FOR i IN 1..4 LOOP
      PERFORM create_user_and_employee(
        'employee' || i || '.' || dept_id || '@techcorp.example.com',
        'Employee' || i,
        'TechCorp' || dept_id,
        org_id,
        dept_id,
        CASE WHEN i = 1 THEN 'manager' ELSE 'employee' END,
        '+3620' || floor(random() * 9000000 + 1000000)::text
      );
    END LOOP;
  END LOOP;
END $$;

-- Create employees for InnoTech Systems
DO $$
DECLARE
  dept_id uuid;
  org_id uuid := '22222222-2222-2222-2222-222222222222';
  emp_id uuid;
  i int;
BEGIN
  -- Create company admin
  PERFORM create_user_and_employee(
    'peter.kovacs@innotech.example.com',
    'Péter',
    'Kovács',
    org_id,
    NULL,
    'company_admin',
    '+36301234567'
  );

  -- Create department employees
  FOR dept_id IN 
    SELECT id FROM departments WHERE organization_id = org_id
  LOOP
    FOR i IN 1..4 LOOP
      PERFORM create_user_and_employee(
        'employee' || i || '.' || dept_id || '@innotech.example.com',
        'Employee' || i,
        'InnoTech' || dept_id,
        org_id,
        dept_id,
        CASE WHEN i = 1 THEN 'manager' ELSE 'employee' END,
        '+3630' || floor(random() * 9000000 + 1000000)::text
      );
    END LOOP;
  END LOOP;
END $$;

-- Create employee_departments connections
INSERT INTO employee_departments (employee_id, department_id)
SELECT e.id, e.department_id
FROM employees e
WHERE e.department_id IS NOT NULL;

-- Cleanup
DROP FUNCTION create_user_and_employee;