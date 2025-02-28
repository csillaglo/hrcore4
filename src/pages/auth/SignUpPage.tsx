import React from 'react';
import { SignUpForm } from '../../components/auth/SignUpForm';
import { Building2 } from 'lucide-react';

export function SignUpPage() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-4 bg-muted/30">
      <div className="mb-8 flex flex-col items-center">
        <Building2 className="h-12 w-12 text-primary mb-2" />
        <h1 className="text-3xl font-bold">OrganizeHub</h1>
      </div>
      <SignUpForm />
    </div>
  );
}