class FriendshipsController < ApplicationController
  def create
    receiver = User.find_by(id: params[:receiver_id])
    return render json: { error: "User not found" }, status: :not_found if receiver.nil?

    friendship = Friendship.new(
      requester: current_user,
      receiver: receiver,
      status: 'pending'
    )

    if friendship.save
      render json: { message: "Friend request sent" }, status: :created
    else
      render json: { errors: friendship.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def incoming
    requests = Friendship.where(receiver: current_user, status: 'pending')
    render json: requests.as_json(include: { requester: { only: [:id, :email, :name] } })
  end

  def accept
    friendship = Friendship.find_by(id: params[:id], receiver: current_user, status: 'pending')
    return render json: { error: "Not found or already handled" }, status: :not_found unless friendship

    friendship.update!(status: 'accepted')
    render json: { message: "Friend request accepted" }
  end

  def deny
    friendship = Friendship.find_by(id: params[:id], receiver: current_user, status: 'pending')
    return render json: { error: "Not found or already handled" }, status: :not_found unless friendship

    friendship.update!(status: 'denied')
    render json: { message: "Friend request denied" }
  end

  def revoke
    friendship = Friendship.find_by(id: params[:id], requester: current_user)
    return render json: { error: "Not found or not yours" }, status: :not_found unless friendship

    friendship.destroy
    render json: { message: "Friendship/relation revoked" }
  end

  def index
    sent = Friendship.where(requester: current_user, status: 'accepted')
    received = Friendship.where(receiver: current_user, status: 'accepted')

    data = []

    sent.each do |f|
      data << {
        friendship_id: f.id,
        user: {
          id: f.receiver.id,
          name: f.receiver.name,
          email: f.receiver.email
        }
      }
    end

    received.each do |f|
      data << {
        friendship_id: f.id,
        user: {
          id: f.requester.id,
          name: f.requester.name,
          email: f.requester.email
        }
      }
    end

    render json: data
  end
end
