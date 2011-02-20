class Object
  def should_receive_delayed(method, *args)
    m = Spec::Mocks::Mock.new('proxy')
    if args.empty?
      m.should_receive(method)
    else
      m.should_receive(method).with(*args)
    end
    self.should_receive(:delay).and_return(m)
  end
end
