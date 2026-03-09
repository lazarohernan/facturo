// Type definitions for Deno Edge Functions
declare const Deno: {
  env: {
    get(key: string): string | undefined;
  };
};

declare module 'https://deno.land/std@0.168.0/http/server.ts' {
  export interface RequestInit {
    method?: string;
    headers?: HeadersInit;
    body?: BodyInit;
  }
  
  export function serve(handler: (req: Request) => Promise<Response>): void;
}

declare module 'https://esm.sh/resend@2.0.0' {
  export class Resend {
    constructor(apiKey: string);
    
    emails: {
      send(options: {
        from: string;
        to: string[];
        subject: string;
        html: string;
      }): Promise<{
        data?: any;
        error?: any;
      }>;
    };
  }
}
