class Person < ActiveRecord::Base

  deferred_has_and_belongs_to_many :teams, before_link: :link_team,
                                           after_link: :linked_team,
                                           before_unlink: :unlink_team,
                                           after_unlink: :unlinked_team,
                                           before_add: :add_team,
                                           after_add: :added_team,
                                           before_remove: :remove_team,
                                           after_remove: :removed_team

  deferred_accepts_nested_attributes_for :teams, allow_destroy: true

  deferred_has_many :issues, before_remove: :remove_issue,
                             after_remove: :removed_issue,
                             dependent: :delete_all
  deferred_accepts_nested_attributes_for :issues, allow_destroy: true

  # has_many without dependent: :delete_all, calling destroy on this association
  # will not destroy the the Issue record
  deferred_has_many :other_issues, before_remove: :remove_issue,
                                   after_remove: :removed_issue,
                                   class_name: 'Issue'

  deferred_has_many :non_validated_issues, before_remove: :remove_issue,
                                  after_remove: :removed_issue,
                                  validate: false

  # Polymorphic has-many association
  deferred_has_many :addresses, as: :addressable,
                                autosave: true,
                                dependent: :delete_all
  deferred_accepts_nested_attributes_for :addresses, allow_destroy: true

  validates_presence_of :name

  def audit_log
    @audit_log ||= []
  end

  def log(audit_line)
    audit_log << audit_line
    audit_log
  end

  def link_team(team)
    if team.new_record?
      log("Before linking new team")
    else
      log("Before linking team #{team.id}")
    end
  end

  def linked_team(team)
    if team.new_record?
      log("After linking new team")
    else
      log("After linking team #{team.id}")
    end
  end

  def unlink_team(team)
    log("Before unlinking team #{team.id}")
  end

  def unlinked_team(team)
    log("After unlinking team #{team.id}")
  end

  def add_team(team)
    if team.new_record?
      log("Before adding new team")
    else
      log("Before adding team #{team.id}")
    end
  end

  def added_team(team)
    log("After adding team #{team.id}")
  end

  def remove_team(team)
    log("Before removing team #{team.id}")
  end

  def removed_team(team)
    log("After removing team #{team.id}")
  end

  def remove_issue(issue)
    log("Before removing issue #{issue.id}")
  end

  def removed_issue(issue)
    log("After removing issue #{issue.id}")
  end
end
