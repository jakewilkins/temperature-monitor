require 'algorithms'
require 'singleton'

class TemperatureNeighborhood
  include Containers
  include Singleton

  TEMP_DB = '/var/temperature_neighborhood_data.json'

  attr_reader :kd_tree, :data_points

  def self.init
    instance.reload!
    EventBus.subscribe(:learn_from_now, instance, :update_model)
  end

  def self.nearest_mean_value(coords)
    instance.nearest_mean_value(coords)
  end

  def nearest_mean_value(coords, k = 3)
    results = nearest(coords, k)
    boolean_mean(results)
  end

  def nearest(coords, k = 3)
    kd_tree.find_nearest(coords, k).map {|(_dist, id)| data_points[id]}
  end

  def update_model(args)
    inside  = TempManager::InsideTemperature.get.value
    outside = TempManager::OutsideTemperature.get.value
    update([inside, outside], StateManager.state)
  end

  def update(coords, val)
    data_points << {coord: coords, value: val}
    File.write(TEMP_DB, JSON.pretty_generate(data_points))
    build_tree
  end

  def reload!
    load_data
    build_tree
  end

  private

  def boolean_mean(results)
    half = results.count / 2
    trues = results.inject(0) {|out, v| v[:value] == 'on' ? out += 1 : out}

    trues > half ? :on : :off
  end

  def load_data
    @data_points = begin
      if File.exists?(TEMP_DB)
        JSON.load(File.read(TEMP_DB))
      else
        # well this is a lot messier than I had planned
        # DATA is only valid for the `main` file.
        JSON.load(File.read(__FILE__).split(/^__END__$\n/)[1])
      end
    end
  end

  def build_tree
    count = -1
    @kd_tree =  Containers::KDTree.new(Hash[data_points.map {|v|
      count += 1
      [count, v['coords']]
    }])
  end

end

__END__
[
  {
    "coords": [
      70,
      70
    ],
    "value": "off"
  },
  {
    "coords": [
      80,
      80
    ],
    "value": "on"
  },
  {
    "coords": [
      77,
      84
    ],
    "value": "on"
  },
  {
    "coords": [
      80,
      90
    ],
    "value": "on"
  },
  {
    "coords": [
      75,
      78
    ],
    "value": "off"
  },
  {
    "coords": [
      60,
      70
    ],
    "value": "off"
  }
]


