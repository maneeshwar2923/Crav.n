import React from 'react';

interface CravnButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'text';
  size?: 'small' | 'medium' | 'large';
  fullWidth?: boolean;
  children: React.ReactNode;
}

export function CravnButton({ 
  variant = 'primary', 
  size = 'medium',
  fullWidth = false,
  className = '',
  children,
  disabled,
  ...props 
}: CravnButtonProps) {
  const baseStyles = 'inline-flex items-center justify-center gap-2 rounded-xl transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed';
  
  const variantStyles = {
    primary: 'bg-[#006D3B] text-white hover:bg-[#008C4D] active:bg-[#004D2A] shadow-[0_4px_12px_rgba(0,109,59,0.25)]',
    secondary: 'bg-white text-[#006D3B] border-2 border-[#006D3B] hover:bg-[#E8F5F0] active:bg-[#E8F5F0]',
    outline: 'bg-transparent text-[#006D3B] border border-[#006D3B] hover:bg-[#E8F5F0]',
    text: 'bg-transparent text-[#006D3B] hover:bg-[#E8F5F0]'
  };
  
  const sizeStyles = {
    small: 'px-4 py-2 text-sm',
    medium: 'px-6 py-3',
    large: 'px-8 py-4'
  };
  
  const widthStyle = fullWidth ? 'w-full' : '';
  
  return (
    <button
      className={`${baseStyles} ${variantStyles[variant]} ${sizeStyles[size]} ${widthStyle} ${className}`}
      disabled={disabled}
      {...props}
    >
      {children}
    </button>
  );
}
