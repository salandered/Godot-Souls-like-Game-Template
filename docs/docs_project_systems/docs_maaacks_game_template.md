# Maaacks game template adoption

Link: https://github.com/Maaack/Godot-Game-Template

## Adoption flow

Quote from the template repo:
> This package is available as both a template and a plugin, meaning it can be used to start a new project, or added to an existing project.

This project was started without using this template. Switching to it functionality occurred later, as I have decided that writing from scratch was too slow and felt like reinventing the wheel.

That's why initially it was used as a plugin (addon) with a current plan in mind:

1. **Integrating its functionality as an addon.**
   - Learning how it works, reusing main components and generally just look at what smart people can do with Godot
1. **Untying core functionality from the addon** and implementing to main project infrastructure logic.
   - Addon comes with examples and also sometimes different implementation of the same thing.
   - We needed to take only parts which were reused during step 1.
   - Result is deleting the dependency, while still relying on big unedited parts of the vanilla functionality.
1. **Editing and shaping functionality**: refactoring what doesn't work for this project and adding new features.
   - Nuance is that while the rapid project growth, "what project needs" and "what doesn't work" are just assumptions which tend to change.
1. Covering the result with tests, writing docs, and **living happily ever after**.

Naturally, second and third steps are most time consuming.

## Where we are

In the middle of the step three.

## What that means

Code is a mix and match of the original code and custom additions/refactoring.
Most of the architectural 'rails' are still the original ideas (and some of them will be staying this way, while some components, most notably UI options menu functionality is planned to be fully rewritten)
