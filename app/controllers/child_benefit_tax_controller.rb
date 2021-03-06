class ChildBenefitTaxController < ApplicationController
  before_filter :setup_navigation_helpers

  CALC_PARAM_KEYS = [:adjusted_net_income, :children_count, :starting_children, :year, :results, :part_year_children_count] +
    AdjustedNetIncomeCalculator::PARAM_KEYS

  def landing
  end

  def process_form
    redirect_hash = { action: :main }

    [:children, :adjusted_income, :results].each do |anchor|
      redirect_hash.merge!(anchor: anchor.to_s) if params[anchor]
    end

    CALC_PARAM_KEYS.each do |name|
      redirect_hash[name] = params[name]
    end

    redirect_to(redirect_hash)
  end

  def main
    @calculator = ChildBenefitTaxCalculator.new(params)
    @adjusted_net_income_calculator = @calculator.adjusted_net_income_calculator
    @calculator.valid? if params[:results]
  end

protected

  def setup_navigation_helpers
    @content_item = Services.content_store.content_item("/child-benefit-tax-calculator").to_hash
    # Remove the organisations from the content item - this will prevent the
    # govuk:analytics:organisations meta tag from being generated until there is
    # a better way of doing this.
    if @content_item["links"]
      @content_item["links"].delete("organisations")
    end

    @navigation_helpers = GovukNavigationHelpers::NavigationHelper.new(@content_item)
    section_name = @content_item.dig("links", "parent", 0, "links", "parent", 0, "title")
    if section_name
      @meta_section = section_name.downcase
    end
  end
end
