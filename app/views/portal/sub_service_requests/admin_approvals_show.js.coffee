$("#modal_area").html("<%= escape_javascript(render(:partial =>'portal/admin/fulfillment/service_request_info/admin_approvals', locals: { sub_service_request: @sub_service_request })) %>");
$("#modal_place").modal 'show'
