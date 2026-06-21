defmodule Afinados.Carburetion.IntakeSizing do
  @moduledoc "Pure intake sizing: diameter from volumetric efficiency, efficiency zone with envelope."

  alias __MODULE__.{
    CommercialSize,
    Displacement,
    EfficiencyZone,
    EngineConfig,
    VolumetricEfficiency
  }

  @rpm_min 2000
  @rpm_max 14_000
  @rpm_step 200
  @commercial_diameters Enum.to_list(10..60//2)

  @spec diameter_at(Displacement.t(), VolumetricEfficiency.t(), %{
          rpm: number(),
          config: EngineConfig.t()
        }) :: float()
  def diameter_at(%Displacement{cc: vt}, %VolumetricEfficiency{value: ev}, %{
        rpm: rpm,
        config: config
      })
      when is_number(rpm) and rpm > 0 do
    diameter_raw(vt, {ev, rpm}, config)
  end

  @spec efficiency_zone(Displacement.t(), VolumetricEfficiency.t(), EngineConfig.t()) ::
          EfficiencyZone.t()
  def efficiency_zone(
        %Displacement{} = displacement,
        %VolumetricEfficiency{} = ve,
        %EngineConfig{} = config
      ) do
    rpms = rpm_range()
    ve_min = VolumetricEfficiency.ve_min()
    ve_max = VolumetricEfficiency.ve_max()
    cc = displacement.cc

    lower = Enum.map(rpms, &%{rpm: &1, diameter: diameter_raw(cc, {ve_min, &1}, config)})
    upper = Enum.map(rpms, &%{rpm: &1, diameter: diameter_raw(cc, {ve_max, &1}, config)})
    curve = Enum.map(rpms, &%{rpm: &1, diameter: diameter_raw(cc, {ve.value, &1}, config)})

    %EfficiencyZone{envelope: %{lower: lower, upper: upper}, curve: curve}
  end

  @spec commercial_lines(Displacement.t(), EngineConfig.t()) :: [CommercialSize.t()]
  def commercial_lines(%Displacement{cc: cc}, %EngineConfig{} = config) do
    ve_min = VolumetricEfficiency.ve_min()
    ve_max = VolumetricEfficiency.ve_max()

    Enum.map(@commercial_diameters, fn d ->
      %CommercialSize{
        diameter: d,
        rpm_window: {
          rpm_for_diameter(d, {cc, ve_max, config}),
          rpm_for_diameter(d, {cc, ve_min, config})
        }
      }
    end)
  end

  defp rpm_for_diameter(d, {cc, ve, %EngineConfig{k: k, carbs: c, cylinders: nc} = config}) do
    p_abs = EngineConfig.p_abs(config)
    d * d * c * 1000 * nc * p_abs / (k * k * cc * ve)
  end

  defp diameter_raw(vt, {ev, rpm}, %EngineConfig{} = config) do
    %EngineConfig{k: k, carbs: c, cylinders: nc} = config
    p_abs = EngineConfig.p_abs(config)
    k * :math.sqrt(vt * rpm * ev / (c * 1000 * nc * p_abs))
  end

  defp rpm_range, do: @rpm_min..@rpm_max//@rpm_step
end
