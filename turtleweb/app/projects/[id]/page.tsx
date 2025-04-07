export default function ProjectDetails({ params }: { params: { id: string } }) {
  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">Project Details</h1>
      <p>Detailed view for project ID: {params.id}</p>
    </div>
  );
}