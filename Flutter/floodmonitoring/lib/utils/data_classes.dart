import 'package:floodmonitoring/utils/colors.dart';

enum VehicleType { pedestrian, bicycle, motorcycle, car, truck }

enum MapStyleType { liberty, fiord, bright }

enum OverlayType { none, floodZones }

enum FloodStatusLevels { nf, patv, nplv, npatv }

enum LocationMode { start, end }

List<Map<String, String>> defaultEmergencyContacts = [
  {
    "name": "Manila DRRMO (Main)",
    "number": "09507003710",
    "description": "City-wide flood rescue & emergency response",
  },
  {
    "name": "Manila City Hall Action Center",
    "number": "89271335",
    "description": "General emergency & flood reports",
  },
  {
    "name": "Philippine Red Cross (Manila)",
    "number": "143",
    "description": "Direct emergency hotline (Shortcode)",
  },
  {
    "name": "MMDA Flood Control",
    "number": "136",
    "description": "Metro-wide flood monitoring & rescue",
  },
  {
    "name": "BFP Manila (Fire/Rescue)",
    "number": "85273627",
    "description": "Bureau of Fire Protection - Manila District",
  },
  {
    "name": "PNP Santa Mesa (Station 6)",
    "number": "87160601",
    "description": "Local police assistance in Santa Mesa",
  },
  {
    "name": "National Emergency Hotline",
    "number": "911",
    "description": "Centralized emergency hotline",
  },
];

class SensorMapVisuals {
  final String id;
  final double lat;
  final double lng;
  final double radius;
  final String status;

  SensorMapVisuals({
    required this.id,
    required this.lat,
    required this.lng,
    required this.radius,
    required this.status,
  });
}

class MapStyles {
  static const Map<MapStyleType, String> styles = {
    MapStyleType.liberty: 'https://tiles.openfreemap.org/styles/liberty',

    MapStyleType.fiord: 'https://tiles.openfreemap.org/styles/fiord',

    MapStyleType.bright: 'https://tiles.openfreemap.org/styles/bright',
  };
}

class FloodStatuses {
  static const Map<FloodStatusLevels, Map<String, dynamic>> floodStatuses = {
    FloodStatusLevels.nf: {
      'color': color_nf,
      'icon': 'assets/images/marker_nf.png',
      'message': "No flooding detected.",
    },
    FloodStatusLevels.patv: {
      'color': color_patv,
      'icon': 'assets/images/marker_patv.png',
      'message':
          "Minor flooding, vehicles can pass. Avoid walking in these areas.",
    },
    FloodStatusLevels.nplv: {
      'color': color_nplv,
      'icon': 'assets/images/marker_nplv.png',
      'message': "Flood levels rising, light vehicles should not pass.",
    },
    FloodStatusLevels.npatv: {
      'color': color_npatv,
      'icon': 'assets/images/marker_npatv.png',
      'message': "Flood levels are dangerous. Do not go to these areas.",
    },
  };
}

class VehicleDict {
  static const Map<VehicleType, Map<String, dynamic>> vehicleList = {
    VehicleType.pedestrian: {
      'passable_flood_cat': [FloodStatusLevels.nf],
      "description":
          "Pedestrians are highly vulnerable during floods. Fast-moving or even shallow floodwaters can cause slips, falls, or being swept away. Walking through flooded areas should be avoided whenever possible.",
      'flood_depth_threshold': 0.0,
      'icon-url': 'assets/images/3d-images/pedestrian-3d.png',
      'stock-url': 'assets/images/stock/stock-image-pedestrian.png',
      'vehicle_tips': """
Walking through floodwater can be dangerous even when the water appears shallow. Floodwater may contain open manholes, debris, electrical hazards, or contaminated water.  

• Avoid walking through moving floodwater whenever possible.  
• Use elevated walkways or safer alternate routes.  
• Wear waterproof boots with good grip to avoid slipping.  
• Do not walk through water if you cannot clearly see the ground.  
• Stay away from electrical posts, exposed wires, and drainage openings.  
• If floodwater rises quickly, move immediately to higher ground.  
""",
    },
    VehicleType.bicycle: {
      'passable_flood_cat': [FloodStatusLevels.nf],
      "description":
          "Bicycles are extremely vulnerable to flooding. Even shallow water can affect balance, braking, and visibility. Riding through flooded areas is highly risky and should be avoided.",
      'flood_depth_threshold': 3.93,
      'icon-url': 'assets/images/3d-images/bell-3d.png',
      'stock-url': 'assets/images/stock/stock-image-bike.png',
      'vehicle_tips': """
Bicycles lack stability in water. Even 10cm of moving water can wash a cyclist away, and submerged hazards are invisible.

• **Check Depth:** If you can't see the bottom, don't ride through. Potholes or missing manhole covers can cause a total wipeout.
• **Walk It:** If you must cross, dismount and walk your bike on the highest ground (usually the center of the road).
• **Braking Power:** Rim brakes lose nearly all effectiveness when wet. Pump your brakes frequently after exiting water to dry them.
• **Avoid Currents:** Never attempt to cross moving water; the lateral pressure on your wheels can easily sweep the bike from under you.
""",
    },
    VehicleType.motorcycle: {
      'passable_flood_cat': [FloodStatusLevels.nf, FloodStatusLevels.patv],
      "description":
          "Motorcycles are very vulnerable to floods even at low levels. Unlike cars and trucks, they can easily lose balance or submerge. Extra caution is needed when riding in flood-prone areas.",
      'flood_depth_threshold': 33.01,
      'icon-url': 'assets/images/3d-images/Motorcycle-3d.png',
      'stock-url': 'assets/images/stock/stock-image-motorcycle.png',
      'vehicle_tips': """
Motorcycles are at high risk of engine "hydro-lock" and loss of traction. Water in the intake will kill the engine instantly.

• **Steady Revs:** Maintain a steady, slightly high RPM in a low gear. Do not let go of the throttle; back-pressure helps prevent water from entering the exhaust.
• **The Bow Wave:** Drive slowly to avoid creating a splash that enters your air intake (usually located under the seat or tank).
• **Center of the Road:** Aim for the crown (middle) of the road where water is shallowest.
• **Post-Flood Check:** After crossing, "drag" your brakes lightly for a few meters to generate heat and dry the pads/discs.
• **Electrical Risk:** If the water reaches the spark plugs, the bike will stall. If it stalls in water, do NOT try to restart it.
""",
    },
    VehicleType.car: {
      'passable_flood_cat': [FloodStatusLevels.nf, FloodStatusLevels.patv],
      "description":
          "Cars can normally withstand floods that are below the door step. They are less vulnerable than motorcycles but may still be at risk if water rises higher than the engine level.",
      'flood_depth_threshold': 33.01,
      'icon-url': 'assets/images/3d-images/car-3d.png',
      'stock-url': 'assets/images/stock/stock-image-car.png',
      'vehicle_tips': """
Modern cars are vulnerable to electronics failure and engine damage in floods. 30cm of water is enough to float many passenger vehicles.

• **The 15cm Rule:** Avoid driving through water deeper than the center of your wheels.
• **One-at-a-Time:** Wait for oncoming traffic to pass. Their "bow wave" can push water over your hood and into your engine intake.
• **Low Gear, High Revs:** In manuals, slip the clutch; in automatics, stay in the lowest gear (L or 1) to keep exhaust pressure up.
• **Don't Stop:** Maintain a slow, constant speed (3-5 mph). Stopping mid-flood allows water to seep into the cabin and exhaust.
• **Brake Test:** Once clear, tap your brakes repeatedly to dry them. Wet brakes have significantly longer stopping distances.
""",
    },
    VehicleType.truck: {
      'passable_flood_cat': [
        FloodStatusLevels.nf,
        FloodStatusLevels.patv,
        FloodStatusLevels.nplv,
      ],
      "description":
          "Trucks can handle large floods because of their size and higher chassis. They are the safest among common vehicles in deep water, but caution is still advised in extreme flood conditions.",
      'flood_depth_threshold': 66.03,
      'icon-url': 'assets/images/3d-images/truck-3d.png',
      'stock-url': 'assets/images/stock/stock-image-truck.png',
      'vehicle_tips': """
While trucks have higher clearance, their large surface area makes them more susceptible to being pushed by strong currents.

• **Check Air Intakes:** Know where your intake is. Many modern trucks have low-mounted intakes that can suck in water even if the body looks high.
• **Cargo Stability:** Water can make a truck buoyant. If your trailer is empty, it is much more likely to float or be swept away.
• **Watch the Wake:** Large tires create significant wakes that can flood smaller vehicles nearby. Be a responsible driver and keep speed at a crawl.
• **Differential Care:** After deep water crossing, have your differentials and transmission fluids checked; water can seep in through breathers and contaminate the oil.
""",
    },
  };
}
