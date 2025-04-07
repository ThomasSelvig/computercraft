export default function CodeEditor({ params }: { params: { id: string } }) {
  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">Code Editor</h1>
      <p>Editor for program ID: {params.id}</p>
    </div>
  );
}