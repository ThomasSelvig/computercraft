export default function ProgramEditPage({ params }: { params: { id: string } }) {
  const isNewProgram = params.id === 'new';
  
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">
        {isNewProgram ? 'Create New Program' : `Edit Program #${params.id}`}
      </h1>
      
      <div className="bg-secondary p-4 rounded-lg shadow mb-4">
        <div className="flex justify-between items-center">
          <div className="flex-1">
            <input 
              type="text" 
              className="w-full p-2 border border-gray-300 rounded bg-background"
              placeholder="Program name"
              defaultValue={isNewProgram ? '' : 'mining.lua'}
            />
          </div>
          <div className="ml-2 flex gap-2">
            <button className="bg-green-500 hover:bg-green-600 px-4 py-2 rounded text-white">Save</button>
            <button className="bg-blue-500 hover:bg-blue-600 px-4 py-2 rounded text-white">Deploy</button>
          </div>
        </div>
      </div>
      
      <div className="h-[70vh] border border-gray-300 rounded bg-gray-900 text-gray-100 font-mono" style={{ fontFamily: 'monospace' }}>
        <div className="p-4">
          <pre>
            {`-- ComputerCraft Turtle Program
-- Mining program with ore detection

local args = { ... }
local width = tonumber(args[1]) or 3
local length = tonumber(args[2]) or 3

function detectOre()
  local success, data = turtle.inspect()
  if success then
    local name = data.name
    return name:find("ore") ~= nil
  end
  return false
end

function mine()
  for y = 1, length do
    for x = 1, width do
      -- Mine forward
      if detectOre() then
        turtle.dig()
      end
      
      if x < width then
        turtle.forward()
      end
    end
    
    -- Turn around for next row
    if y < length then
      if y % 2 == 1 then
        turtle.turnRight()
        turtle.forward()
        turtle.turnRight()
      else
        turtle.turnLeft()
        turtle.forward()
        turtle.turnLeft()
      end
    end
  end
  
  return true
end

print("Starting mining operation...")
mine()
print("Mining complete!")`}
          </pre>
        </div>
      </div>
    </div>
  );
}