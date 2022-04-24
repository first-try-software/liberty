RSpec.describe Liberty::Router::Printer do
  describe '#print' do
    subject(:print) { router.print(stdout) }

    let(:router) { Liberty::Router.new }
    let(:stdout) { StringIO.new }
    let(:endpoint) { class_double('endpoint', to_s: 'Endpoint') }

    before do
      router.delete('/tasks/:id', to: endpoint)
      router.get('/tasks', to: endpoint)
      router.put('/tasks/:id', to: endpoint)
      router.get('/ahoy', to: endpoint)
      router.post('/tasks', to: endpoint)
      router.get('/tasks/:id', to: endpoint)
      router.get('/tasks/all/:user_id', to: endpoint)
      router.get('/tasks/:user_id/all', to: endpoint)

      print
    end

    it 'prints the routes sorted by path and verb' do
      expect(stdout.string).to eq(
<<-ROUTES
     GET /ahoy                                              => Endpoint
    HEAD /ahoy                                              => Endpoint
     GET /tasks                                             => Endpoint
    HEAD /tasks                                             => Endpoint
    POST /tasks                                             => Endpoint
     GET /tasks/:id                                         => Endpoint
    HEAD /tasks/:id                                         => Endpoint
     PUT /tasks/:id                                         => Endpoint
  DELETE /tasks/:id                                         => Endpoint
     GET /tasks/:user_id/all                                => Endpoint
    HEAD /tasks/:user_id/all                                => Endpoint
     GET /tasks/all/:user_id                                => Endpoint
    HEAD /tasks/all/:user_id                                => Endpoint
ROUTES
      )
    end
  end
end
