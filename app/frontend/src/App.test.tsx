import { cleanup, fireEvent, render, screen } from "@testing-library/react"
import { afterEach, describe, expect, it, vi } from "vitest"
import App from "./App"

afterEach(() => {
  cleanup()
  vi.unstubAllGlobals()
})

describe("App", () => {
  it("mostra a mensagem devolvida pela API ao clicar no botão", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn(async () => ({
        ok: true,
        json: async () => ({ message: "Olá do PostgreSQL", totalClicks: 3 }),
      })),
    )
    render(<App />)
    fireEvent.click(screen.getByRole("button", { name: /obter mensagem/i }))
    expect(await screen.findByText("Olá do PostgreSQL")).toBeTruthy()
    expect(await screen.findByText(/Total de cliques registados: 3/)).toBeTruthy()
  })

  it("mostra um erro quando a API falha", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn(async () => {
        throw new Error("network error")
      }),
    )
    render(<App />)
    fireEvent.click(screen.getByRole("button", { name: /obter mensagem/i }))
    expect(await screen.findByRole("alert")).toBeTruthy()
  })
})
