import { Sidebar } from "@/components/Sidebar";
import { MobileNav } from "@/components/MobileNav";

export function DocsLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <MobileNav />
      <main className="flex-1 min-w-0">
        <div className="mx-auto max-w-4xl px-6 py-12 lg:px-12 lg:py-16">
          <div className="prose max-w-none">{children}</div>
        </div>
      </main>
    </div>
  );
}