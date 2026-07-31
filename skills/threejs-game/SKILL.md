---
name: threejs-game
description: Design, build, refactor, optimize, test, and release maintainable three.js games across runtime architecture, assets, rendering, input and camera, interaction and UI, physics, animation, materials and VFX, performance, save and networking, WebXR, and QA. Use for any game-oriented three.js task; do not use for generic non-game 3D pages or data visualization.
---

# Goal

Use one end-to-end engineering skill for three.js game work. Select only the relevant internal tracks, preserve cross-system boundaries, and produce an implementation or review that is runnable, measurable, disposable, and releaseable.

This skill replaces the former `threejs-game-*` installable family. Do not route work to child skills or require users to install additional Three.js skills.

# Activation

Use this skill when the work includes one or more of:

- a persistent frame loop, gameplay state, player control, collision, animation, saving, networking, or XR
- turning a three.js demo into a maintainable game codebase
- adding or auditing assets, rendering, interaction, physics, VFX, performance, testing, or release workflows for a game
- diagnosing a cross-system game issue whose root cause may span runtime, assets, rendering, input, physics, or lifecycle management

Do not use it for a static product viewer, marketing scene, data visualization, or decorative 3D page unless game-like runtime and interaction constraints are materially present.

# Required context

Gather what is available; mark unknowns rather than inventing them:

- game type and camera model
- target platforms, browsers, devices, and input methods
- WebGL, WebGPU, or dual-backend requirement
- visual style and asset sources
- single-player, save/replay, or multiplayer requirements
- XR requirement
- current repository state, build tool, TypeScript usage, test stack, and known performance constraints

For an existing repository, inspect its structure, package scripts, renderer setup, loop, loaders, state model, disposal paths, and tests before proposing architecture.

# Operating rules

1. **Do not treat three.js as a full game engine.** Keep gameplay state, services, lifecycle, assets, physics, persistence, and QA explicit.
2. **Do not activate every track by default.** Use the smallest track set that closes the requested task.
3. **Prefer stable WebGL unless WebGPU or TSL provides a demonstrated benefit.** State compatibility and fallback boundaries.
4. **Use glTF or GLB as the production runtime asset format.** Treat FBX, OBJ, and DCC files as sources.
5. **Separate logical truth from visual representation.** Scene graph state is not the save format or network protocol.
6. **Measure before optimizing.** Define budgets and evidence, then change the bottleneck.
7. **Every created service needs an owner and a disposal path.**
8. **Preserve one-way boundaries.** Gameplay consumes abstractions; it must not reach through them into DOM events, renderer internals, physics engine instances, or raw asset trees.
9. **Validate behavior, not just file presence or keywords.** Include runnable checks for the changed path.
10. **Keep changes reviewable.** Avoid coupling runtime, rendering, physics, networking, and content migrations in one unbounded change.

# Internal track selection

| Track | Activate when | Minimum output |
| --- | --- | --- |
| Runtime | New project, demo-to-product refactor, lifecycle or loop changes | Service boundaries, loop order, resize and disposal flow |
| Assets | Models, animation clips, textures, prefabs, compression, loading | Runtime format, conventions, loader and validation chain |
| Rendering | Color, lighting, shadows, transparency, post-processing, backend choice | Rendering baseline and visual/performance budgets |
| Input and camera | Keyboard, mouse, pointer lock, gamepad, touch, camera modes | Action map, focus modes, camera rules, recovery behavior |
| Interaction and UI | Picking, triggers, prompts, HUD, world-space UI | Interaction model, state machine, event and UI boundaries |
| Physics | Blocking, character movement, rigid bodies, scene queries | Adapter, layer matrix, controller and query contracts |
| Animation | Character/object stateful animation, retargeting, IK | Animator boundary, state graph, clip and event conventions |
| Materials and VFX | Custom shaders, TSL, particles, procedural effects | Effect classification, backend path, fallback and budget |
| Performance | Frame drops, memory growth, large scenes, streaming | Baseline, budget, bottleneck evidence, prioritized fixes |
| State and network | Save/load, checkpoints, replay, multiplayer | Serializable schema, authority/sync model, restore path |
| XR | VR, MR, WebXR platform support | Session lifecycle, controls, comfort, UI and frame budget |
| QA and release | Any production change | Test layer, asset/visual/browser checks, release gate |

# End-to-end workflow

## 1. Classify the task and scope

State:

- whether this is a game or a non-game 3D application
- the requested outcome and affected player path
- active tracks and explicitly inactive tracks
- backend, platform, device, compatibility, and performance constraints
- repository evidence that supports the proposed change

For a focused task, do not redesign unrelated tracks. For a new game or broad refactor, establish the baseline in this order:

1. runtime and lifecycle
2. asset contract
3. rendering baseline
4. input, camera, interaction, and physics
5. animation and gameplay state
6. VFX and platform-specific features
7. persistence, networking, or XR
8. performance, QA, and release gates

## 2. Establish the runtime boundary

Default baseline:

```text
src/
  main.ts
  app/GameApp.ts
  render/{RendererService,CameraService,SceneService}.ts
  world/WorldRoot.ts
  input/InputService.ts
  interaction/InteractionService.ts
  assets/AssetRegistry.ts
  ui/UiRoot.ts
  shared/{events,types}.ts
```

Adapt this to the repository instead of forcing filenames mechanically.

Requirements:

- keep the entry point focused on composition
- centralize renderer creation and resize handling
- use one time source with `rawDelta`, `gameDelta`, and optional `fixedDelta`
- make loop stages explicit: input, gameplay, animation, physics, late update, render, metrics
- provide `init`, `start`, `pause`, `resume`, and `dispose` semantics
- prevent modules from silently creating extra renderers, cameras, clocks, or global listeners
- clean up listeners, animation mixers, physics objects, render targets, geometries, materials, and textures

Use `renderer.setAnimationLoop()` when it fits browser, XR, and backend requirements. Explain exceptions.

## 3. Define the asset contract

Production assets should use glTF or GLB and a repeatable import path.

Define:

- coordinate system, forward direction, units, origin, root node, and scale rules
- clip, socket, collision proxy, trigger, and LOD naming
- required nodes and metadata for each prefab
- texture roles and color-space treatment
- whether negative scale is permitted
- loader setup for Draco, Meshopt, and KTX2 when used

Choose compression deliberately:

- Draco reduces geometry transfer size but adds decode cost
- Meshopt often provides a balanced runtime path
- KTX2/Basis is preferred for large texture sets and constrained devices
- glTF-Transform or gltfpack may optimize offline, but must preserve runtime-required nodes, extras, skins, and clips

Validation must include glTF validation, runtime loading, clip enumeration, material and texture integrity, transform spot checks, and prefab-required-node checks. Business code should query an `AssetRegistry` or prefab wrapper, not repeatedly traverse raw model trees by guessed names.

## 4. Set the rendering baseline

Make these explicit:

- output color space, tone mapping, exposure, and texture color/data classification
- WebGL, WebGPU, or dual-backend strategy
- PBR and environment lighting strategy, including PMREM where applicable
- shadow-casting lights, shadow map budgets, and object eligibility
- transparency categories and sorting limitations
- post-processing passes and their platform budgets

Rules:

- do not compensate for missing environment lighting with arbitrary direct-light intensity
- use `alphaTest`-style solutions for suitable cutout content before general transparency
- do not enable shadows or expensive post effects globally
- prefer built-in materials; custom shaders, TSL, or compute require a concrete need
- vertex displacement and procedural transparency must account for depth, shadows, picking, and motion data

## 5. Build input, camera, interaction, and physics boundaries

### Input and camera

Raw DOM or device events enter one input layer. Gameplay consumes semantic actions and axes.

Define:

- digital actions, analog axes, and system actions
- keyboard, mouse, pointer lock, gamepad, touch, and optional XR mappings
- dead zones, sensitivity, inversion, acceleration, and frame-rate behavior
- modes such as gameplay, menu, text input, paused, cutscene, and debug
- pointer-lock denial, focus loss, device disconnect, and recovery behavior
- FPS, TPS, top-down, RTS, or other camera constraints and collision behavior

### Interaction and UI

Interactive entities must be registered or component-tagged rather than inferred from arbitrary node names.

Select among:

- ray casting for sparse or directed queries
- trigger volumes for enter/exit and region logic
- GPU picking for large, skinned, transparent, or shader-deformed candidate sets

Keep world entities from directly mutating the full HUD. Route candidate, focus, start, complete, cancel, enter, and exit events through an interaction boundary. World-space UI needs distance, visibility, occlusion, and focus rules.

### Physics and collision

Keep render meshes, collision proxies, gameplay rules, and physics implementation separate.

Choose deliberately:

- Octree, BVH, or a lightweight custom layer for mostly static worlds and constrained queries
- Rapier when full rigid bodies, character controllers, scene queries, snapshots, or stronger tooling are required
- a lighter engine only when its limitations fit the project

Define:

- a `PhysicsAdapter`
- collision and overlap layer matrix
- character movement, gravity, grounding, steps, slopes, walls, jump windows, and moving platforms where applicable
- unified raycast, sweep, overlap, ground probe, and line-of-sight APIs
- fixed-step and interpolation behavior
- snapshot or determinism expectations for replay or networking

## 6. Add animation only through a controller boundary

Do not scatter direct `mixer.clipAction("Run")` calls through gameplay.

Define:

- clip naming and required groups
- Animator or character animation controller ownership
- locomotion, airborne, action, reaction, cinematic, and disabled states as needed
- blending, hard transitions, cancel windows, root-motion boundaries, and animation events
- retargeting and skeleton compatibility for shared motion sets
- sockets for equipment and attachments
- IK only for demonstrated needs such as feet, hands, aim, look-at, or interaction reach

Gameplay state and animation state may correspond, but they are not the same state machine.

## 7. Add materials, VFX, and GPU work with explicit fallbacks

Classify each effect as:

- material/surface
- vertex or geometry deformation
- particle
- screen-space/post-processing
- instanced state
- compute-driven simulation

Prefer the smallest implementation:

- built-in material parameters
- `onBeforeCompile`
- `ShaderMaterial` or `RawShaderMaterial`
- instancing and attributes/data textures
- EffectComposer on the WebGL path
- TSL, storage buffers, or compute on a justified WebGPU path

Centralize custom materials, expose debug and quality switches, define low-spec fallback behavior, and measure GPU cost. Do not embed broad gameplay state inside a monolithic shader.

## 8. Separate state, save, replay, and networking from the scene graph

At minimum distinguish:

- persistent game state
- transient runtime state
- derived visual state
- profile/settings state
- session-only state

A save schema should include versioning, level or seed identity, player state, progression, entity state, timestamps, integrity/migration hooks, and an explicit restore flow. Use IndexedDB for substantial production saves; use localStorage only for small settings or trivial data.

For networking, state the authority model: authoritative server, host-client, or P2P. Separate input, event, and state synchronization. Define prediction, reconciliation, latency, snapshot, and physics boundaries only to the level needed by the task. Never serialize or synchronize the entire three.js scene as the source of truth.

## 9. Apply XR as a platform mode, not a camera patch

Define:

- non-XR, entering, active, paused, exiting, and cleanup states
- controller, hand, gaze, ray, grab, UI, and locomotion mappings
- room-scale versus seated behavior
- teleport, snap-turn, smooth movement, height calibration, and handedness rules
- world-space, controller-attached, or wrist UI
- XR frame-rate target and stricter shadow, post-processing, and draw-call budgets
- WebGL/WebGPU and device compatibility, plus non-XR fallback

Comfort is a release criterion. Do not copy desktop controls directly into XR.

## 10. Measure and protect performance

Establish evidence before optimization:

- frame time and target FPS
- draw calls and triangles
- CPU main-thread and subsystem update time
- GPU time where measurable
- texture and render-target memory
- geometry, material, texture, and program counts from `renderer.info`
- loading, activation, cache, and unload time

Default optimization order:

1. eliminate lifecycle leaks and unintended duplicate work
2. reduce draw calls through material reuse, instancing, batching, and content structure
3. right-size and compress textures and assets
4. constrain shadows, transparency, particles, and post-processing
5. profile CPU hotspots and allocation/GC pressure
6. introduce workers, OffscreenCanvas, compute, or architectural complexity only with evidence

Large scenes need preload, activation, cache, unload, and distance/region streaming policies.

## 11. Validate and release

Use layered validation:

- unit tests for pure rules, transforms, mappings, parsers, and save migrations
- integration tests for runtime composition, registries, animation transitions, physics adapters, and restore paths
- browser/E2E smoke tests for launch, loading, movement, interaction, UI, and save recovery
- asset validation for glTF integrity, clips, textures, naming, and prefab requirements
- visual regression for representative lighting, close-up, distance, transparency, and VFX scenes
- browser, device, input, and XR checks appropriate to the support matrix
- performance comparison against the declared baseline and budgets
- release checks for production build, resource paths, sourcemaps, package size, initial load, errors, and cleanup

A changed path is not complete if only static text, filenames, or keyword tests pass while runtime behavior remains unverified.

# Output contract

For a focused task, return:

1. task classification and active tracks
2. repository evidence and affected boundaries
3. concrete implementation or patch plan
4. key design decisions and rejected alternatives
5. validation, performance, compatibility, and disposal checks
6. residual risks and explicitly deferred work

For a broad project or audit, return:

1. project and platform classification
2. architecture and state boundaries
3. asset and rendering baseline
4. input, interaction, physics, and animation design
5. optional VFX, networking, or XR design
6. performance budgets and instrumentation
7. QA and release gates
8. smallest executable next unit

# Legacy ID migration

The following former installable skill IDs are now internal sections of `threejs-game` and must not be requested or emitted as dependencies:

- `threejs-game-bootstrap-runtime`
- `threejs-game-asset-pipeline`
- `threejs-game-render-lighting`
- `threejs-game-input-camera`
- `threejs-game-interaction-ui`
- `threejs-game-physics-collision`
- `threejs-game-animation-character`
- `threejs-game-materials-tsl-vfx`
- `threejs-game-performance-profiler`
- `threejs-game-save-load-network`
- `threejs-game-xr-platform`
- `threejs-game-tooling-qa-release`

# Common failure modes

- replacing the old family with one router that still references deleted child skills
- concatenating all old templates without resolving duplicated rules or workflow order
- forcing every track into a small change
- allowing raw DOM, asset-tree, renderer, or physics-engine access throughout gameplay code
- starting with shaders or WebGPU before runtime, assets, and budgets are stable
- serializing the scene graph as save or network state
- treating a visual smoke test as sufficient lifecycle, performance, or behavior validation
- optimizing without measurements or adding complexity without a rollback path

# Primary references

- three.js manual and docs: game structure, WebGLRenderer, WebGPURenderer, color management, glTF loading, cleanup, picking, animation, instancing, post-processing, TSL, and WebXR
- Khronos glTF specification and validator
- glTF-Transform, meshoptimizer/gltfpack, Draco, and KTX2 documentation
- MDN Pointer Lock, Gamepad, IndexedDB, WebSocket, RTCDataChannel, OffscreenCanvas, and WebXR documentation
- Rapier, cannon-es, and three-mesh-bvh documentation when those dependencies are selected
- Vitest and Playwright documentation for automated validation
