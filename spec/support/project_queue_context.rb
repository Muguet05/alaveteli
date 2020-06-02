RSpec.shared_context 'Project::Queue context' do
  let(:project) do
    project = FactoryBot.create(:project,
                                contributors_count: 2,
                                classifiable_requests_count: 2,
                                extractable_requests_count: 2)

    # HACK: extractable_requests_count uses attributes_for. The factory it
    # relies on uses an after_create callback to call set_described_state to
    # create an event and update the state, meaning our
    # extractable_requests_count doesn't actually work.
    project.info_requests.last(2).each do |info_request|
      info_request.update(described_state: 'successful')
    end

    project
  end

  let(:current_user) { project.contributors.last }

  let(:backend) do
    queue_name = described_class.to_s.demodulize.underscore
    Project::Queue::SessionBackend.primed({}, project, queue_name)
  end

  let(:info_requests) { project.info_requests }

  let(:queue) { described_class.new(info_requests, backend) }
end
