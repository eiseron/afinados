defmodule Afinados.Carburetion.IntakeSizing do
  @moduledoc "Pure intake sizing centered on peak gas velocity through the venturi."

  alias __MODULE__.{Displacement, EngineConfig, VolumetricEfficiency}

  @commercial_diameters Enum.to_list(10..60//2)

  @spec commercial_diameters() :: [pos_integer()]
  def commercial_diameters, do: @commercial_diameters

  @spec target_velocity(EngineConfig.t()) :: float()
  def target_velocity(%EngineConfig{k: k} = config) do
    p_abs = EngineConfig.p_abs(config)
    100.0 * p_abs / (:math.pi() * k * k)
  end

  @spec gas_velocity(number(), number(), %{
          displacement: Displacement.t(),
          ve: VolumetricEfficiency.t(),
          config: EngineConfig.t()
        }) :: float()
  def gas_velocity(diameter, rpm, %{
        displacement: %Displacement{cc: cc},
        ve: %VolumetricEfficiency{value: ev},
        config: %EngineConfig{} = config
      })
      when is_number(diameter) and diameter > 0 and is_number(rpm) and rpm > 0 do
    n = EngineConfig.pulse_divisor(config)
    ff = EngineConfig.fuel_factor(config)
    cc * ev * ff * rpm / (10 * n * :math.pi() * diameter * diameter)
  end

  @spec rpm_for_velocity(number(), number(), %{
          displacement: Displacement.t(),
          ve: VolumetricEfficiency.t(),
          config: EngineConfig.t()
        }) :: float()
  def rpm_for_velocity(diameter, velocity, %{
        displacement: %Displacement{cc: cc},
        ve: %VolumetricEfficiency{value: ev},
        config: %EngineConfig{} = config
      })
      when is_number(diameter) and diameter > 0 and is_number(velocity) and velocity > 0 do
    n = EngineConfig.pulse_divisor(config)
    ff = EngineConfig.fuel_factor(config)
    velocity * 10 * n * :math.pi() * diameter * diameter / (cc * ev * ff)
  end
end
