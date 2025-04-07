export default function TurtleDetails({ params }: { params: { id: string } }) {
  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">Turtle Details</h1>
      <p>Detailed view for turtle ID: {params.id}</p>
    </div>
  );
}