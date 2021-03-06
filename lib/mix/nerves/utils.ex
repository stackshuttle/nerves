defmodule Mix.Nerves.Utils do

  def shell(cmd) do
    stream = IO.binstream(:standard_io, :line)
    Application.put_env(:porcelain, :driver, Porcelain.Driver.Basic)
    Application.ensure_started(:porcelain)
    Porcelain.shell(cmd, in: stream, async_in: true, out: stream, err: :out)
  end

  def preflight do
    check_requirements
    Mix.Task.run "nerves.loadpaths", []
  end

  def check_requirements do
    case System.cmd("which", ["mksquashfs"]) do
      {_, 0} -> nil
      _ -> Mix.raise """
      Squash FS Tools are required to be installed on your system.
      Please see https://hexdocs.pm/nerves/installation.html#host-specific-tools
      for installation instructions
      """
    end

    case System.cmd("which", ["fwup"]) do
      {_, 0} -> nil
      _ -> Mix.raise """
      fwup is required to create and burn firmware.
      Please see https://hexdocs.pm/nerves/installation.html#fwup
      for installation instructions
      """
    end

    {_, type} = :os.type
    check_host_requirements(type)
  end

  def check_host_requirements(:darwin) do
    case System.cmd("which", ["gstat"]) do
      {_, 0} -> nil
      _ -> Mix.raise """
      gstat is required to create and burn firmware.
      Please see https://hexdocs.pm/nerves/installation.html#host-specific-tools
      for installation instructions
      """
    end
  end
  def check_host_requirements(_), do: nil
end
