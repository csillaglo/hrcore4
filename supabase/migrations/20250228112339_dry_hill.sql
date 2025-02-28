/*
  # Fix sample data insertion with proper type casting

  1. Changes
    - Drop and recreate sample data with proper role casting
    - Use proper type casting for user_role enum
    - Add proper error handling
*/

-- First, clean up any existing sample data
DELETE FROM employee_departments;
DELETE FROM employees;
DELETE FROM departments WHERE id IN (
  'c1111111-1111-1111-1111-111111111111',
  'c1111111-1111-1111-1111-111111111112',
  'c1111111-1111-1111-1111-111111111113',
  'c1111111-1111-1111-1111-111111111114',
  'c1111111-1111-1111-1111-111111111115',
  'c2222222-2222-2222-2222-222222222221',
  'c2222222-2222-2222-2222-222222222222',
  'c2222222-2222-2222-2222-222222222223',
  'c2222222-2222-2222-2222-222222222224',
  'c2222222-2222-2222-2222-222222222225'
);
DELETE FROM organizations WHERE id IN (
  '11111111-1111-1111-1111-111111111111',
  '22222222-2222-2222-2222-222222222222'
);

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

-- Create employees for TechCorp Solutions
DO $$
DECLARE
  dept_id uuid;
  org_id uuid := '11111111-1111-1111-1111-111111111111';
  v_user_id uuid;
BEGIN
  -- Create company admin first
  v_user_id := gen_random_uuid();
  
  -- Create auth user for admin
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
    'janos.nagy@techcorp.example.com',
    now(),
    jsonb_build_object(
      'first_name', 'János',
      'last_name', 'Nagy'
    ),
    now(),
    now(),
    '',
    '',
    '',
    ''
  );

  -- Create admin employee with proper role casting
  INSERT INTO employees (
    id,
    organization_id,
    first_name,
    last_name,
    email,
    role,
    phone,
    is_active
  ) VALUES (
    v_user_id,
    org_id,
    'János',
    'Nagy',
    'janos.nagy@techcorp.example.com',
    'company_admin'::user_role,
    '+36201234567',
    true
  );

  -- Create department employees
  FOR dept_id IN 
    SELECT id FROM departments WHERE organization_id = org_id
  LOOP
    FOR i IN 1..4 LOOP
      v_user_id := gen_random_uuid();
      
      -- Create auth user
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
        'employee' || i || '.' || dept_id || '@techcorp.example.com',
        now(),
        jsonb_build_object(
          'first_name', 'Employee' || i,
          'last_name', 'TechCorp' || dept_id
        ),
        now(),
        now(),
        '',
        '',
        '',
        ''
      );

      -- Create employee with proper role casting
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
        org_id,
        dept_id,
        'Employee' || i,
        'TechCorp' || dept_id,
        'employee' || i || '.' || dept_id || '@techcorp.example.com',
        CASE 
          WHEN i = 1 THEN 'manager'::user_role
          ELSE 'employee'::user_role
        END,
        '+3620' || floor(random() * 9000000 + 1000000)::text,
        true
      );

      -- Create department association
      INSERT INTO employee_departments (employee_id, department_id)
      VALUES (v_user_id, dept_id);
    END LOOP;
  END LOOP;
END $$;

-- Create employees for InnoTech Systems
DO $$
DECLARE
  dept_id uuid;
  org_id uuid := '22222222-2222-2222-2222-222222222222';
  v_user_id uuid;
BEGIN
  -- Create company admin first
  v_user_id := gen_random_uuid();
  
  -- Create auth user for admin
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
    'peter.kovacs@innotech.example.com',
    now(),
    jsonb_build_object(
      'first_name', 'Péter',
      'last_name', 'Kovács'
    ),
    now(),
    now(),
    '',
    '',
    '',
    ''
  );

  -- Create admin employee with proper role casting
  INSERT INTO employees (
    id,
    organization_id,
    first_name,
    last_name,
    email,
    role,
    phone,
    is_active
  ) VALUES (
    v_user_id,
    org_id,
    'Péter',
    'Kovács',
    'peter.kovacs@innotech.example.com',
    'company_admin'::user_role,
    '+36301234567',
    true
  );

  -- Create department employees
  FOR dept_id IN 
    SELECT id FROM departments WHERE organization_id = org_id
  LOOP
    FOR i IN 1..4 LOOP
      v_user_id := gen_random_uuid();
      
      -- Create auth user
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
        'employee' || i || '.' || dept_id || '@innotech.example.com',
        now(),
        jsonb_build_object(
          'first_name', 'Employee' || i,
          'last_name', 'InnoTech' || dept_id
        ),
        now(),
        now(),
        '',
        '',
        '',
        ''
      );

      -- Create employee with proper role casting
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
        org_id,
        dept_id,
        'Employee' || i,
        'InnoTech' || dept_id,
        'employee' || i || '.' || dept_id || '@innotech.example.com',
        CASE 
          WHEN i = 1 THEN 'manager'::user_role
          ELSE 'employee'::user_role
        END,
        '+3630' || floor(random() * 9000000 + 1000000)::text,
        true
      );

      -- Create department association
      INSERT INTO employee_departments (employee_id, department_id)
      VALUES (v_user_id, dept_id);
    END LOOP;
  END LOOP;
END $$;