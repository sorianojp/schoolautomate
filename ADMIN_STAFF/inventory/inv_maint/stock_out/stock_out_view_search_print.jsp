<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<body onLoad="javascript:window.print()" bgcolor="#FFFFFF">
<%@ page language="java" import="utility.*,inventory.InventorySearch,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-InventorySearch Print","requisition_view_search_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	InventorySearch InvSearch = new InventorySearch();
	Vector vRetResult = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending"};	
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"Requisition No.","Requisition Date","Requisition Status","College","Department"};
	String[] astrSortByVal     = {"req_number","request_date","requisition_status","c_code","d_name"};

	int iSearch = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	int i = 0;
	boolean bolPageBreak = false;
	double dGrandTotalItems = 0d;
	double dTotalItems = 0d;

	vRetResult = InvSearch.searchStockOutRequest(dbOP,request);
	if(vRetResult != null)
		iSearch = InvSearch.getSearchCount();
	if(vRetResult != null ){
	for(;i < vRetResult.size();){
		dTotalItems = 0d;		
%>
<form name="form_" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
    <td height="25" colspan="2"><div align="center">
            <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
        </div></td>
  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td><font size="1">Requisition No.</font></td>
      <td><strong><font size="1">
        <%if(WI.fillTextValue("req_no_select").equals("equals")){%>
        <%=WI.getStrValue(WI.fillTextValue("req_num"),"-")%>
        <%}else if(WI.fillTextValue("req_no_select").equals("contains")){%>
        <%=WI.fillTextValue("req_no_select") +" - "+ WI.getStrValue(WI.fillTextValue("req_num"),"-")%>
        <%}else{%>
        <%=WI.fillTextValue("req_no_select") +" with - "+ WI.getStrValue(WI.fillTextValue("req_num"),"-")%>
        <%}%>
        </font></strong></td>
      <td><font size="1">Requested by</font></td>
      <td><strong><font size="1">
        <%if(WI.fillTextValue("req_by_select").equals("equals")){%>
        <%=WI.getStrValue(WI.fillTextValue("req_by"),"-")%>
        <%}else if(WI.fillTextValue("req_no_select").equals("contains")){%>
        <%=WI.fillTextValue("req_by_select") +" - "+ WI.getStrValue(WI.fillTextValue("req_by"),"-")%>
        <%}else{%>
        <%=WI.fillTextValue("req_by_select") +" with - "+ WI.getStrValue(WI.fillTextValue("req_by"),"-")%>
        <%}%>
        </font></strong></td>
    </tr>
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="20%"><font size="1">Date Requested</font></td>
      <td width="26%"><strong><font size="1"><%=WI.getStrValue(WI.fillTextValue("date_req_fr"),"-")+WI.getStrValue(WI.fillTextValue("date_req_to")," - ","","")%></font></strong></td>
      <td width="20%"><font size="1">Requisition Status</font></td>
      <td width="31%"><strong><font size="1">
        <%if(WI.fillTextValue("req_status").length() > 0){%>
        <%=astrReqStatus[Integer.parseInt(WI.fillTextValue("req_status"))]%>
        <%}else{%>
        All
        <%}%>
        </font></strong></td>
    </tr>
    
    <%if((WI.fillTextValue("c_index")).equals("0")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><font size="1">Non-Acad. Office/Dept</font></td>
      <td><strong><font size="1">
        <%if(WI.fillTextValue("d_index").equals("0")){%>
        All
        <%}else{%>
        <%=dbOP.mapOneToOther("DEPARTMENT","D_INDEX",WI.fillTextValue("d_index"),"D_NAME","")%>
        <%}%>
        </font></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%}else{%>
    <tr>
      <td height="26">&nbsp;</td>
      <td><font size="1">College/Dept</font></td>
      <td><strong><font size="1"><%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",WI.fillTextValue("c_index"),"C_NAME",""),"All")+"/"+WI.getStrValue(dbOP.mapOneToOther("DEPARTMENT","D_INDEX",WI.fillTextValue("d_index"),"D_NAME",""),"All")%></font></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
  </table>
  <br>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td  height="25" colspan="7"  class="thinborder"><div align="center"><strong>LIST
          OF REQUESTS</strong></div></td>
	</tr>
	<tr>
      <td colspan="7"  class="thinborder"><strong>TOTAL RESULT : <%=iSearch%></strong></td>
    </tr>
    <tr>
	  <td width="8%" align="center"  class="thinborder"><strong> COUNT NO.</strong></td>
      <td width="25%"  height="25" align="center"  class="thinborder"><strong>OFFICE/DEPT</strong></td>
      <td width="22%" align="center"  class="thinborder"><strong>REQUISITION
      NO.</strong></td>
      <td width="12%" align="center"  class="thinborder"><strong>DATE
      REQUESTED</strong></td>
      <td width="19%" align="center"  class="thinborder"><strong>REQUESTED
      BY</strong></td>
      <td width="8%" align="center"  class="thinborder"><strong>STATUS</strong></td>
      <td width="6%" align="center"  class="thinborder"><strong>TOTAL
      ITEMS </strong></td>
    </tr>
	<%
 	for(int iCount = 0; iCount <= iMaxRecPerPage; i += 8,++iCount){
  		if (iCount >= iMaxRecPerPage || i >= vRetResult.size()){
			if(i >= vRetResult.size())
				bolPageBreak = false;
			else
				bolPageBreak = true;
			break;
	 }%>
    <tr>
	  <td  class="thinborder"><div align="center"><%=(i+8)/8%></div></td>
      <td  class="thinborder" height="25">
        &nbsp;
        <%if(((String)vRetResult.elementAt(i+5)) != null){%>
        <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"N/A") +"/"+ WI.getStrValue((String)vRetResult.elementAt(i+6),"All")%>
        <%}else{%>
        <%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%>
        <%}%></td>
      <td  class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+1)%></div></td>
      <td  class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+4)%></div></td>
      <td  class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td  class="thinborder">&nbsp;<%=astrReqStatus[Integer.parseInt((String)vRetResult.elementAt(i+2))]%></td>
      <td  class="thinborder"><div align="right">
          <%if(vRetResult.elementAt(i+7) == null || ((String)vRetResult.elementAt(i+7)).equals("0")){%>
          &nbsp;
          <%}else{%>
          <%=(String)vRetResult.elementAt(i+7)%>
          <%}%>
          </div></td>
    </tr>
	<%  if(((String)vRetResult.elementAt(i+7)) != null && ((String)vRetResult.elementAt(i+7)).length() > 0) 
			dTotalItems += Double.parseDouble((String)vRetResult.elementAt(i+7));

	}%>
    <tr>
      <td  class="thinborder" height="25" colspan="6"><div align="left"></div>
        <div align="right"><strong>PAGE TOTAL :&nbsp; &nbsp;&nbsp;</strong></div></td>
      <td  class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalItems,false)%></strong></div></td>
    </tr>
	<%
	dGrandTotalItems += dTotalItems;
   if (i >= vRetResult.size()){
   %>
  <tr>
      <td  class="thinborder" height="25" colspan="6"><div align="left"></div>
        <div align="right"><strong>OVERALL SEARCH TOTAL :&nbsp;
          &nbsp;&nbsp;</strong></div></td>
      <td  class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dGrandTotalItems,false)%></strong></div></td>
    </tr>
  <tr>
    <td class="thinborder" colspan="7" ><div align="center"> *****************NOTHING FOLLOWS *******************</div></td>
  </tr>
   <%}else{%>
  <tr>
    <td class="thinborder" colspan="7" ><div align="center"> ************** CONTINUED ON NEXT PAGE ****************</div></td>
  </tr>
  <%}%>
</table>
  <%
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END.
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }
	}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
