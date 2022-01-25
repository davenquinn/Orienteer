import { render, screen } from "@testing-library/react";
import "regenerator-runtime/runtime";
import h from "@macrostrat/hyper";
import App, { testText } from "./app";

test("render h1 element", () => {
  render(h(App));
  expect(screen.getByText(testText)).toBeInTheDocument();
});
