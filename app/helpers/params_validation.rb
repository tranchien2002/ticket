module ParamsValidation

  PARAMS_VALIDATION = {
    new: {
      admin_new_topic: {
        params_structure: {
          user_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      admin_new_user: {
        post_id: {
          status: Settings.params_attribute_status.required,
          validation: [
            {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
          ]
        }
      },
      new_doc: {
        params_structure: {
          category_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          post_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      }
    },
    edit: {
      admin_edit_user: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      admin_edit_post: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      edit_group: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      edit_forum: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      edit_doc: {
        params_structure: {
          category_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      }
    },
    create: {
      admin_split_topic: {
        params_structure: {
          topic_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present?", message: "Topic Id không hợp lệ"}
            ]
          },
          post_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present?", message: "Post Id không hợp lệ"}
            ]
          }
        }
      },
      admin_merge_tickets: {
        params_structure: {
          topic_ids: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present?", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      admin_create_topic: {
        params_structure: {
          post: {
            status: Settings.params_attribute_status.required
          }
          topic: {
            status: Settings.params_attribute_status.required,
            name: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            team_list: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            channel: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            tag_list: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            screenshots: {
              status: Settings.params_attribute_status.required,
              validation: []
            }
          }
        }
      },
      admin_create_post: {
        params_structure: {
          post: {
            status: Settings.params_attribute_status.required,
            body: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            kind: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            screenshots: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            attachments: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            cc: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            bcc: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            user_id: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
              ]
            },
            resolved: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present? && var.is_a?(String)", message: "Resolved không hợp lệ"}
              ]
            }
          }
        }
      },
      create_image: {
        params_structure: {
          image: {
            status: Settings.params_attribute_status.required,
            name: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            extension: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            file: {
              status: Settings.params_attribute_status.optional,
              validation: []
            }
          }
        }
      },
      create_group: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          acts_as_taggable_on_tag: {
            status: Settings.params_structure.required,
            name: {
              status: Settings.params_structure.optional,
              validation: []
            },
            description: {
              status: Settings.params_structure.optional,
              validation: []
            },
            color: {
              status: Settings.params_structure.optional,
              validation: []
            },
            email_address: {
              status: Settings.params_structure.optional,
              validation: []
            },
            email_name: {
              status: Settings.params_structure.optional,
              validation: []
            },
            show_on_helpcenter: {
              status: Settings.params_structure.optional,
              validation: []
            },
            show_on_admin: {
              status: Settings.params_structure.optional,
              validation: []
            },
            show_on_dashboard: {
              status: Settings.params_structure.optional,
              validation: []
            }
          }
        }
      },
      create_forum: {
        params_structure: {
          forum: {
            status: Settings.params_attribute_status.required,
            name: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present?", message: "Tên Forum không hợp lệ"}
              ]
            },
            description: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            layout: {
              status: Settings.params_attribute_status.optional,
              validation: [
            },
            private: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            allow_topic_voting: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            allow_post_voting: {
              status: Settings.params_attribute_status.optional,
              validation: []
            }
          }
        }
      },
      up_vote: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          user_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      create_doc: {
        params_structure: {
          doc: {
            status: Settings.params_attribute_status.required,
            title: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Tiêu đề không hợp lệ"}
              ]
            },
            body: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            keywords: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Từ khóa không hợp lệ"}
              ]
            },
            title_tag: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Tiêu đề không hợp lệ"}
              ]
            },
            meta_description: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            category_id: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
              ]
            },
            rank: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present? && var.is_a?(Fixnum)", message: "Rank không hợp lệ"}
              ]
            },
            active: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            front_page: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            allow_comments: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            screenshots: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            tag_list: {
              status: Settings.params_attribute_status.required,
              validation: []
            }
          }
        }
      },
      create_category: {
        params_structure: {
          category: {
            status: Settings.params_attribute_status.required,
            name: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Tên không hợp lệ"}
              ]
            },
            keywords: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Từ khóa không hợp lệ"}
              ]
            },
            title_tag: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            icon: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            meta_description: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            front_page: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            active: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Trạng thái không hợp lệ"}
              ]
            },
            section: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            rank: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Rank không hợp lệ"}
              ]
            },
            team_list: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Danh sách không hợp lệ"}
              ]
            },
            visibility: {
              status: Settings.params_attribute_status.optional,
              validation: []
            }
          }
        }
      },

      create_topic: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: []
          }
          topic: {
            status: Settings.params_attribute_status.required,
            name: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present?", message: "Tên topic không hợp lệ"}
              ]
            },
            private: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present?", message: "Trường private không hợp lệ"}
              ]
            },
            doc_id: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
              ]
            },
            team_list: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present?", message: "team list không hợp lệ"}
              ]
            },
            posts_attributes: {
              validation: [
                {expression: "var.present?", message: "post không hợp lệ"}
              ]
            },
            screenshots: {
              validation: [
                {expression: "var.present?", message: "Screenshots không hợp lệ"}
              ]
            },
          }
        }
      },

      create_post: {
        params_structure: {
          post: {
            status: Settings.params_attribute_status.required,
            screenshots: {
              validation: [
                {expression: "var.present?", message: "Screenshots không hợp lệ"}
              ]
            }
          },
          topic_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },

      create_flag: {
        params_structure: {
          post_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          flag: {
            status: Settings.params_attribute_status.required,
            reason: {
              Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present?", message: "Id không hợp lệ"}
              ]
            }
          }
        }
      },

      apartment_user: {
        params_structure: {
          post: {
            status: Settings.params_attribute_status.required,
            body: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present?", message: "Nội dung không hợp lệ"}
              ]
            },
            kind: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present?", message: "Kind không hợp lệ"}
              ]
            },
            user_id: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
              ]
            },
            attachments: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present? && var.is_a?(Array)", message: "Tệp đính kèm không hợp lệ"}
              ]
            }
          }
        }
      }
    },

    destroy: {
      destroy_group: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      destroy_forum: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      destroy_doc: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      destroy_category: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      }
    },
    update: {
      admin_assign_agent: {
        params_structure: {
          assigned_user_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          topic_ids: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      admin_update_topic: {
        params_structure: {
          topic_ids: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
        }
      },
      admin_update_user: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          user: {
            status: Settings.params_attribute_status.required,
            team_list: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            role: {
              status: Settings.params_attribute_status.required,
              validation: []
            }
          },
          page: {
            status: Settings.params_attribute_status.required,
            validation: []
          }
        }
      },
      admin_update_order: {
        params_structure: {
          object: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: ""}
            ]
          },
          obj_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          row_order_position: {
            status: Settings.params_attribute_status.required,
            validation: []
          }
        }
      },
      change_owner_new_user: {
        params_structure: {
          post_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          user: {
            status: Settings.params_attribute_status.required,
            name: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present? && var.is_a?(String)", message: "Tên không hợp lệ"}
              ]
            },
            email: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present? && var.is_a?(String)", message: "Email không hợp lệ"}
              ]
            }
          }
        }
      },
      admin_update_post: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          post: {
            status: Settings.params_attribute_status.required,
            body: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            kind: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            screenshots: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            attachments: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            cc: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            bcc: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            user_id: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
              ]
            },
            resolved: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present? && var.is_a?(String)", message: "Resolved không hợp lệ"}
              ]
            }
          }
        }
      },
      update_group: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          acts_as_taggable_on_tag: {
            status: Settings.params_structure.required,
            name: {
              status: Settings.params_structure.optional,
              validation: []
            },
            description: {
              status: Settings.params_structure.optional,
              validation: []
            },
            color: {
              status: Settings.params_structure.optional,
              validation: []
            },
            email_address: {
              status: Settings.params_structure.optional,
              validation: []
            },
            email_name: {
              status: Settings.params_structure.optional,
              validation: []
            },
            show_on_helpcenter: {
              status: Settings.params_structure.optional,
              validation: []
            },
            show_on_admin: {
              status: Settings.params_structure.optional,
              validation: []
            },
            show_on_dashboard: {
              status: Settings.params_structure.optional,
              validation: []
            }
          }
        }
      },
      update_forum: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      update_doc: {
        create_doc: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
          doc: {
            status: Settings.params_attribute_status.required,
            title: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Tiêu đề không hợp lệ"}
              ]
            },
            body: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            keywords: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Từ khóa không hợp lệ"}
              ]
            },
            title_tag: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Tiêu đề không hợp lệ"}
              ]
            },
            meta_description: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            category_id: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
              ]
            },
            rank: {
              status: Settings.params_attribute_status.required,
              validation: [
                {expression: "var.present? && var.is_a?(Fixnum)", message: "Rank không hợp lệ"}
              ]
            },
            active: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            front_page: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            allow_comments: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            screenshots: {
              status: Settings.params_attribute_status.required,
              validation: []
            },
            tag_list: {
              status: Settings.params_attribute_status.required,
              validation: []
            }
          }
        }
      }
      },
      update_category: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
          category: {
            status: Settings.params_attribute_status.required,
            name: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Tên không hợp lệ"}
              ]
            },
            keywords: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Từ khóa không hợp lệ"}
              ]
            },
            title_tag: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            icon: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            meta_description: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            front_page: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            active: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Trạng thái không hợp lệ"}
              ]
            },
            section: {
              status: Settings.params_attribute_status.optional,
              validation: []
            },
            rank: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Rank không hợp lệ"}
              ]
            },
            team_list: {
              status: Settings.params_attribute_status.optional,
              validation: [
                {expression: "var.present?", message: "Danh sách không hợp lệ"}
              ]
            },
            visibility: {
              status: Settings.params_attribute_status.optional,
              validation: []
            }
          }
        }
      },
    },
    get: {
      admin_toggle_privacy: {
        params_structure: {
          topic_ids: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          forum_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          private: {
            status: Settings.params_attribute_status.optional,
            validation: [
              {expression: "var.present?", message: ""}
            ]
          }
        }
      },
      admin_unassign_team: {
        params_structure: {
          topic_ids: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      merge_tickets: {
        params_structure: {
          topic_ids: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      admin_get_tickets: {
        params_structure: {
          page: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Page không hợp lệ"}
            ]
          }
        }
      },
      admin_show_user: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          page: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Page không hợp lêj"}
            ]
          }
        }
      },
      admin_list_user: {
        params_structure: {
          role: {
            status: Settings.params_attribute_status.required,
            validation: []
          },
          page: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Page không hợp lêj"}
            ]
          }
        }
      },
      admin_show_topic: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      admin_get_topics: {
        params_structure: {
          status: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(String)", message: "Trang thái không hợp lệ"}
            ]
          },
          page: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Page không hợp lêj"}
            ]
          }
        }
      },
      preview: {
        params_structure: {
          theme: {
            status: Settings.params_attribute_status.optional,
            validation: []
          }
        }
      },
      search_date_from_params: {
        params_structure: {
          start_date: {
            status: Settings.params_attribute_status.optional,
            validation: []
          },
          end_date: {
            status: Settings.params_attribute_status.optional,
            validation: []
          }
        }
      },
      topic_search: {
        params_structure: {
          q: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present?", message: ""}
            ]
          },
          page: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Page không hợp lệ"}
            ]
          }
        }
      },
      post_raw: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      admin_search_post: {
        params_structure: {
          user_search: {
            status: Settings.params_attribute_status.optional,
            validation: []
          },
          post_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      admin_cancel_post: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      doc_available_to_view: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      show_internal_category: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          page: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Page không hợp lệ"}
            ]
          }
        }
      },
      get_doc: {
        params_structure: {
          doc_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },

      show_category: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          page: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Page không hợp lệ"}
            ]
          }
        }
      },

      doc_available_to_view: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },

      show_forum: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },

      up_vote: {
        params_structure: {
          id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      search_result: {
        params_structure: {
          query: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present?", message: "Truy vấn không hợp lệ"}
            ]
          }
        }
      },

      topic_index: {
        params_structure: {
          forum_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Id không hợp lệ"}
            ]
          },
          page: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Page không hợp lệ"}
            ]
          }
        }
      },

      tickets: {
        params_structure: {
          page: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present? && var.is_a?(Fixnum)", message: "Page không hợp lệ"}
            ]
          }
        }
      }

    }
  }
end
