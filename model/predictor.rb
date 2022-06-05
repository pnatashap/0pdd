require_relative './pso/pso'

def argsort(arr)
  arr.map.with_index.sort.map(&:last)
end

def normalised_kendall_tau_distance(a, b)
  raise 'Both lists have to be of equal length' unless a.size == b.size
  a = argsort(a)
  b = argsort(b)
  combination = a.combination(2)
  disordered = 0
  combination.each do |i, j|
    is_disordered = (a[i] > a[j] && b[i] < b[j]) || (a[i] < a[j] && b[i] > b[j])
    disordered += 1 if is_disordered
  end
  n = a.size
  (2.0 * disordered.to_f) / (n * (n - 1.0))
end

def default_option_generator_linear(attribute_num)
  [
    { 'layers': [{ 'name': 'w1', 'shape': [attribute_num, 1] }, { 'name': 'w2', 'shape': [1, 1] }] },
    [attribute_num] + 1
  ]
end

#
# Linear Predictor Model
#
class Predictor
  def initialize(**options)
    @layers = {}
    @kendall_corr_history = []
    options[:layers].each do |layer|
      @layers["#{layer[:name]}_shape"] = layer[:shape]
    end
  end

  def f(model_weights, **options)
    data = options[:data]
    true_order = options[:true_order]
    kns = []
    # history_per_backlog = []
    (0...data.size).each do |i|
      x = data[i]
      y = true_order[i].first(x.size)
      m = model_weights.first(x.size)
      preds = predict(m, x, y)
      kn = normalised_kendall_tau_distance(preds, y)
      kns.append(kn)
    end
    kns.sum / kns.size # mean
  end

  def train(model_weights, data, true_order, debug = false)
    ranks = predict(model_weights, data, true_order, debug)
    normalised_kendall_tau_distance(ranks, true_order)
  end

  def predict(model_weights, data, true_order = [], debug = false)
    ranks = []
    (0...data.size).each do |i|
      row = data[i]
      weights = model_weights.first(row.size)
      r = forward_one(weights, row)
      ranks.append(r)
    end
    if debug
        puts "-- Pred Rank \n#{argsort(ranks)}\n--"
        puts "-- True Rank \n#{argsort(true_order)}\n--\n" if true_order
    end
    ranks
  end

  def forward_one(model_weights, data)
    x = data.clone.map(&:clone).flatten
    w = model_weights
    x = Vector[*x].dot(Vector[*w])
    w.map { |c| x += c }[0]
  end

  def kendall(model_weights, data, true_order, _full = true)
    x = predict(model_weights, data)
    normalised_kendall_tau_distance(x, true_order)
  end
end

# optimizer = ps.single.GlobalBestPSO(n_particles=400, dimensions=param_size, options=options)
# cost, pos = optimizer.optimize(p.train_full, iters=15,
#                   data=X,
#                   true_order=Y,
#                   verbose=True)
# #  where X is the set of repositories and Y is the set of order of task solving, like [[1,2,3], [5,4,3,2,1]]

# for repo in repositories
#   predictions = p.forward(pos, x, y)
#   kn = normalised_kendall_tau_distance(predictions, y)
# # here x - a repo, and y - a order of task execution

# y = [[1, 2, 3]]
# data = [[[0.1, 0.3, 0.8, 1, -0.2, -0.6], [1, -0.3, 0.5, 0, 0.2, -0.6], [0.3, 0.3, -0.9, -0.5, -1, 0.7]]]
