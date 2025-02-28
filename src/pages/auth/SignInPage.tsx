import React from 'react';
import { SignInForm } from '../../components/auth/SignInForm';
import { Building2 } from 'lucide-react';

export function SignInPage() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-4 bg-muted/30">
      <div className="mb-8 flex flex-col items-center">
        <Building2 className="h-12 w-12 text-primary mb-2" />
        <h1 className="text-3xl font-bold">OrganizeHub</h1>
      </div>
      <SignInForm />
    </div>
  );
}