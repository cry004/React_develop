require 'test_helper'

class DeviceTest < ActiveSupport::TestCase
  let(:token_params) do
    'b15cb71b531bd2e5619f615d608eb39754dd14dc8e7a309b960d17ade9841b6a'
  end

  let(:badge_number) { Device::DEFAULT_BADGE_NUMBER }
  let(:sound)        { Device::DEFAULT_NOTIFY_SOUND }
  let(:silent_flag)  { Device::SILENT_FLAG_ENABLE }
  describe '.sns_client' do
    subject { Device.sns_client }
    it { assert_instance_of(Aws::SNS::Client, subject) }
  end

  describe '.notify' do
    subject { Device.notify(post, type) }

    let(:post) { Post.find(39) } # from fixtures
    let(:type) { 'type' }

    before do
      Device.skip_callback(:save, :before)
      Device.create!(pushable_type: 'Student', pushable_id: 2, token: 'token', os: 'ios')
      Device.set_callback(:save, :before)
    end

    it 'calls Device#push method with valid arguments' do
      args = nil
      proc = -> (*arguments) { args = arguments }
      Device.stub_any_instance(:push, proc) do
        subject
      end
      assert_instance_of(Aws::SNS::Client, args[0])
      assert_equal(badge_number, args[1])
      assert_equal(post, args[2])
      assert_equal(type, args[3])
      assert_equal(sound, args[5])
      assert_equal(6, args.size)
    end
  end

  describe '.notify_silent' do

    subject { Device.notify_silent(student) }

    let(:student) { Student.second } # from fixtures

    before do
      Device.skip_callback(:save, :before)
      Device.create!(pushable_type: 'Student', pushable_id: 2, token: 'token', os: 'ios')
      Device.set_callback(:save, :before)
    end

    it 'calls Device#push method with valid arguments' do
      args = nil
      proc = -> (*arguments) { args = arguments }
      Device.stub_any_instance(:push, proc) do
        subject
      end
      assert_instance_of(Aws::SNS::Client, args[0])
      assert_equal(student.unread_notification_num, args[1])
      assert_equal(silent_flag, args[4])
      assert_equal(5, args.size)
    end
  end

  describe '.bulk_notify' do
    before { VCR.insert_cassette('device_bulk_notify') }
    after { VCR.eject_cassette }

    let(:device) do
      Device.create(pushable: pushable_params,
                    os:       os_params,
                    token:    token_params)
    end
    let(:os_params)       { 'ios' }
    let(:pushable_params) { Student.first }
    let(:message_param)   { Settings.push_notification_message.default }
    let(:topic_arn_name)  { Settings.whole_student_notification_topic }
    let(:news_id)         { News.take.id }

    subject { Device.bulk_notify(message_param, topic_arn_name, news_id) }

    it { assert(subject) }

    it 'calls Aws::SNS::Client#publish with valid args' do
      args = nil
      proc = -> (*arguments) { args = arguments }
      Aws::SNS::Client.stub_any_instance(:publish, proc) do
        subject
      end
      assert_equal(1, args.size)
      assert_equal(topic_arn_name, args[0][:target_arn])
      assert_equal(Device.notification_message_json(nil, nil, message_param, news_id, badge_number, nil, sound), args[0][:message])
      assert_equal('json', args[0][:message_structure])
    end
  end

  describe '#delete_endpoint_arn' do
    before { VCR.insert_cassette('device_delete_endpoint_arn') }
    after { VCR.eject_cassette }

    let(:device) do
      Device.create(pushable: pushable_params,
                    os:       os_params,
                    token:    token_params)
    end
    let(:os_params)       { 'ios' }
    let(:pushable_params) { Student.first }

    subject { device.send(:delete_endpoint_arn) }

    it { assert(subject) }

    it 'is private method' do
      assert(Device.private_instance_methods.include?(:delete_endpoint_arn))
    end

    it 'calls Aws::SNS::Client#delete_endpoint with valid args' do
      args = nil
      proc = -> (argument) { args = argument }
      Aws::SNS::Client.stub_any_instance(:delete_endpoint, proc) do
        subject
      end
      assert({ endpoint_arn: device.endpoint_arn }, args)
    end
  end

  describe '#subscribe_whole_student_notification' do
    let(:device) { Device.new }
    subject { device.send(:subscribe_whole_student_notification) }

    it 'is private method' do
      methods = Device.private_instance_methods
      assert(methods.include?(:subscribe_whole_student_notification))
    end

    it 'calls Device#subscribe_topic_arn' do
      args = nil
      proc = -> (argument) { args = argument }
      Device.stub_any_instance(:subscribe_topic_arn, proc) do
        subject
      end
      assert(Settings.whole_student_notification_topic, args)
    end
  end

  describe '#subscribe_topic_arn' do
    before { VCR.insert_cassette('device_subscribe_topic_arn') }
    after { VCR.eject_cassette }

    let(:device) do
      Device.create(pushable: pushable_params,
                    os:       os_params,
                    token:    token_params)
    end
    let(:os_params)       { 'ios' }
    let(:pushable_params) { Student.first }
    let(:topic_arn_name)  { Settings.whole_student_notification_topic }

    subject { device.send(:subscribe_topic_arn, topic_arn_name) }

    it { assert(subject) }

    it 'is private method' do
      methods = Device.private_instance_methods
      assert(methods.include?(:subscribe_topic_arn))
    end

    it 'calls Aws::SNS::Client#subscribe' do
      called = false
      proc = -> (_) { called = true }
      Aws::SNS::Client.stub_any_instance(:subscribe, proc) do
        subject
      end
      assert(called)
    end
  end
end
