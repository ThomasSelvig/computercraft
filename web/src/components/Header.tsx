import ConnectionStatus from './ConnectionStatus';

const Header = () => {
  return (
    <header className="bg-primary text-white px-8 py-4 flex justify-between items-center shadow-md">
      <h1 className="text-xl font-semibold">ComputerCraft Turtle Control Center</h1>
      <ConnectionStatus />
    </header>
  );
};

export default Header;