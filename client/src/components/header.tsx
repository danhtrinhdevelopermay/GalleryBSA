import { Car, Bell, User } from "lucide-react";

export default function Header() {
  return (
    <header className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center space-x-4">
            <Car className="text-primary text-2xl" />
            <h1 className="text-xl font-semibold text-secondary">Vehicle Manager</h1>
          </div>
          
          <nav className="hidden md:flex items-center space-x-6">
            <a href="#" className="text-primary font-medium border-b-2 border-primary pb-1">
              Dashboard
            </a>
            <a href="#" className="text-gray-600 hover:text-primary transition-colors">
              Vehicles
            </a>
            <a href="#" className="text-gray-600 hover:text-primary transition-colors">
              Reports
            </a>
            <a href="#" className="text-gray-600 hover:text-primary transition-colors">
              Settings
            </a>
          </nav>
          
          <div className="flex items-center space-x-3">
            <button className="p-2 text-gray-600 hover:text-primary transition-colors">
              <Bell className="w-5 h-5" />
            </button>
            <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center">
              <User className="text-white text-sm" />
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}
