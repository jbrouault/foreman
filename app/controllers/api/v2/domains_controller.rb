module Api
  module V2
    class DomainsController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      resource_description do
        # TRANSLATORS: API documentation - do not translate
        desc <<-DOC
          Foreman considers a domain and a DNS zone as the same thing. That is, if you
          are planning to manage a site where all the machines are or the form
          <i>hostname</i>.<b>somewhere.com</b> then the domain is <b>somewhere.com</b>.
          This allows Foreman to associate a puppet variable with a domain/site
          and automatically append this variable to all external node requests made
          by machines at that site.
        DOC
      end

      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/domains/", "List of domains"
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @domains = Domain.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/domains/:id/", "Show a domain."
      param :id, :identifier, :required => true, :desc => "May be numerical id or domain name"

      def show
      end

      def_param_group :domain do
        param :domain, Hash, :action_aware => true do
          param :name, String, :required => true, :desc => "The full DNS Domain name"
          param :fullname, String, :required => false, :allow_nil => true, :desc => "Full name describing the domain"
          param :dns_id, :number, :required => false, :allow_nil => true, :desc => "DNS Proxy to use within this domain"
          param :domain_parameters_attributes, Array, :required => false, :desc => "Array of parameters (name, value)"
        end
      end

      api :POST, "/domains/", "Create a domain."
      # TRANSLATORS: API documentation - do not translate
      description <<-DOC
        The <b>fullname</b> field is used for human readability in reports
        and other pages that refer to domains, and also available as
        an external node parameter
      DOC
      param_group :domain, :as => :create

      def create
        @domain = Domain.new(params[:domain])
        process_response @domain.save
      end

      api :PUT, "/domains/:id/", "Update a domain."
      param :id, :identifier, :required => true
      param_group :domain

      def update
        process_response @domain.update_attributes(params[:domain])
      end

      api :DELETE, "/domains/:id/", "Delete a domain."
      param :id, :identifier, :required => true

      def destroy
        process_response @domain.destroy
      end
    end
  end
end
