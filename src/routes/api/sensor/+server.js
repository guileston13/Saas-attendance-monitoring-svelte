// src/routes/api/camera/+server.js
let cameraStatus = { start: false };

export async function POST({ request }) {
  const { action } = await request.json();

  if (action === "camera_start") {
    console.log("Sensor triggered: START camera");
    cameraStatus.start = true;
    return new Response(JSON.stringify({ status: "camera_started" }), {
      status: 200,
      headers: { "Content-Type": "application/json" }
    });
  }

  if (action === "camera_stop") {
    console.log("Sensor triggered: STOP camera");
    cameraStatus.start = false;
    return new Response(JSON.stringify({ status: "camera_stopped" }), {
      status: 200,
      headers: { "Content-Type": "application/json" }
    });
  }

  return new Response(JSON.stringify({ status: "unknown_action" }), {
    status: 400,
    headers: { "Content-Type": "application/json" }
  });
}

export async function GET() {
  return new Response(JSON.stringify(cameraStatus), {
    status: 200,
    headers: { "Content-Type": "application/json" }
  });
}
