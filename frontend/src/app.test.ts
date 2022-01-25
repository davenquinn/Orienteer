import { render, screen } from "@testing-library/react";
import h from "@macrostrat/hyper";
import App, { canaryText } from "./app";

test("render h1 element", () => {
  render(h(App));
  expect(screen.getByText(canaryText)).toBeInTheDocument();
});
