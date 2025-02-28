/*
  # Add sample data

  1. New Data
    - 2 organizations
    - 5 departments per organization
    - 4 employees per department
    - 1 admin per organization

  2. Structure
    - Organizations: Tech companies
    - Departments: Different business units
    - Employees: Mix of roles and positions
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

-- Create employees for TechCorp Solutions departments
DO $$
DECLARE
  dept_id uuid;
  org_id uuid := '11111111-1111-1111-1111-111111111111';
  i int;
BEGIN
  -- Create company admin first
  INSERT INTO employees (id, organization_id, first_name, last_name, email, role, phone, is_active)
  VALUES (
    gen_random_uuid(),
    org_id,
    'János',
    'Nagy',
    'janos.nagy@techcorp.example.com',
    'company_admin',
    '+36201234567',
    true
  );

  FOR dept_id IN 
    SELECT id FROM departments WHERE organization_id = org_id
  LOOP
    FOR i IN 1..4 LOOP
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
      )
      VALUES (
        gen_random_uuid(),
        org_id,
        dept_id,
        'Employee' || i,
        'TechCorp' || dept_id,
        'employee' || i || '.' || dept_id || '@techcorp.example.com',
        CASE 
          WHEN i = 1 THEN 'manager'
          ELSE 'employee'
        END,
        '+3620' || floor(random() * 9000000 + 1000000)::text,
        true
      );
    END LOOP;
  END LOOP;
END $$;

-- Create employees for InnoTech Systems departments
DO $$
DECLARE
  dept_id uuid;
  org_id uuid := '22222222-2222-2222-2222-222222222222';
  i int;
BEGIN
  -- Create company admin first
  INSERT INTO employees (id, organization_id, first_name, last_name, email, role, phone, is_active)
  VALUES (
    gen_random_uuid(),
    org_id,
    'Péter',
    'Kovács',
    'peter.kovacs@innotech.example.com',
    'company_admin',
    '+36301234567',
    true
  );

  FOR dept_id IN 
    SELECT id FROM departments WHERE organization_id = org_id
  LOOP
    FOR i IN 1..4 LOOP
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
      )
      VALUES (
        gen_random_uuid(),
        org_id,
        dept_id,
        'Employee' || i,
        'InnoTech' || dept_id,
        'employee' || i || '.' || dept_id || '@innotech.example.com',
        CASE 
          WHEN i = 1 THEN 'manager'
          ELSE 'employee'
        END,
        '+3630' || floor(random() * 9000000 + 1000000)::text,
        true
      );
    END LOOP;
  END LOOP;
END $$;

-- Create employee_departments connections
INSERT INTO employee_departments (employee_id, department_id)
SELECT e.id, e.department_id
FROM employees e
WHERE e.department_id IS NOT NULL;