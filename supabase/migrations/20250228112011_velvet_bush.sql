/*
  # Fix role casting in employee creation function

  1. Changes
    - Drop existing function
    - Recreate function with proper role casting
*/

-- Drop existing function if exists
DROP FUNCTION IF EXISTS create_user_and_employee;

-- Recreate function with proper role casting
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

  -- Create employee record with proper role casting
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
    p_role::user_role,  -- Cast the role string to user_role enum
    p_phone,
    true
  );

  RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;