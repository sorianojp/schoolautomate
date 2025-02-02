<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,purchasing.Requisition,purchasing.PO,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	
	if(WI.fillTextValue("req_no").length() > 0){%>
		<jsp:forward page="requisition_view.jsp"/>
	<%return;}

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-PURCHASE ORDER"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-PURCHASE ORDER-View Print PO","purhase_request_view_search_print.jsp");
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
	
	Requisition REQ = new Requisition();
	PO PO = new PO();
	Vector vRetResult = null;
	String[] astrPOStatus = {"Disapproved","Approved","Pending"};
	String[] astrBudget = {"Not in the Budget","Within Budget"};
	int iDefault = 0;
	int iSearch = 0;
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	int iLoop = 1;
	boolean bolPageBreak = false;
	double dGrandTotalItems = 0d;
	double dTotalItems = 0d;
	double dTotalAmount = 0d;
	
	vRetResult = PO.operateOnSearchListPO(dbOP,request);
	if(vRetResult == null)
		strErrMsg = PO.getErrMsg();
	else
		iSearch = PO.getSearchCount();
	
	if(vRetResult != null ){
	for(;iLoop < vRetResult.size();){
		dTotalItems = 0d;
		dTotalAmount = 0d;	
%>
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
      <td width="3%" height="26">&nbsp;</td>
      <td width="20%"><font size="1">PO No.</font></td>
      <td width="26%"><strong><font size="1"> 
        <%if(WI.fillTextValue("po_no_select").equals("equals")){%>
        <%=WI.getStrValue(WI.fillTextValue("po_no"),"-")%> 
        <%}else if(WI.fillTextValue("po_no_select").equals("contains")){%>
        <%=WI.fillTextValue("po_no_select") +" - "+ WI.getStrValue(WI.fillTextValue("po_no"),"-")%> 
        <%}else{%>
        <%=WI.fillTextValue("po_no_select") +" with - "+ WI.getStrValue(WI.fillTextValue("po_no"),"-")%> 
        <%}%>
        </font></td>
      <td width="20%"><font size="1">Status</font></td>
      <td width="31%"><strong><font size="1">
	  <%if(WI.fillTextValue("status").length() > 0){%>
	  <%=astrPOStatus[Integer.parseInt(WI.fillTextValue("status"))]%> 
	  <%}else{%>
	  All
	  <%}%>
	  </font></strong>
	  </td>
    </tr>
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
      <td><font size="1">Requested By</font></td>
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
    <%if((WI.fillTextValue("c_index")).equals("0")){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Office</font></td>
      <td><strong><font size="1"><%if(WI.fillTextValue("d_index").equals("0")){%>
	  All
	  <%}else{%>
	  <%=dbOP.mapOneToOther("DEPARTMENT","D_INDEX",WI.fillTextValue("d_index"),"D_NAME","")%>
	  <%}%>
</font></strong></td>
      <td><font size="1">Budget</font></td>
      <td><strong><font size="1">
	  <%if(WI.fillTextValue("budget").length() > 0){%>
	  <%=astrBudget[Integer.parseInt(WI.fillTextValue("budget"))]%>
	  <%}else{%>
	  All
	  <%}%>
	  </font></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</font></td>
      <td><strong><font size="1"><%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",WI.fillTextValue("c_index"),"C_NAME",""),"All")+"/"+WI.getStrValue(dbOP.mapOneToOther("DEPARTMENT","D_INDEX",WI.fillTextValue("d_index"),"D_NAME",""),"All")%></font></strong></td>
      <td><font size="1">Budget</font></td>
      <td><font size="1"><strong>
	  <%if(WI.fillTextValue("budget").length() > 0){%>
	  <%=astrBudget[Integer.parseInt(WI.fillTextValue("budget"))]%>
	  <%}else{%>
	  All
	  <%}%>
	  </strong></font></td>
    </tr>
    <%}%>
  </table>
  <br>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td  height="25" colspan="9" class="thinborder"><div align="center"><strong>LIST 
          OF REQUESTED ITEMS / SUPPLIES</strong></div></td>
    </tr>
    <tr> 
      <td colspan="9" class="thinborder"><strong>TOTAL RESULT 
        : <%=iSearch%></strong></td>
    </tr>
    <tr> 
      <td width="4%" class="thinborder"><div align="center"><strong> 
          COUNT NO.</strong></div></td>
      <td width="9%"  height="25" class="thinborder"><div align="center"><strong>PO 
          DATE </strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>PO 
          NO. </strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>REQUISITION 
          NO.</strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>COLLEGE/DEPT</strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>NON-ACAD 
          OFFICE/DEPT</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>PO 
          STATUS</strong></div></td>
      <td width="4%" class="thinborder"><div align="center"><strong>TOTAL 
          ITEMS </strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>TOTAL 
          AMOUNT</strong></div></td>
    </tr>
    <% 
 	for(int iCount = 0; iCount <= iMaxStudPerPage; iLoop += 10,++iCount){
  		if (iCount >= iMaxStudPerPage || iLoop >= vRetResult.size()){
			if(iLoop >= vRetResult.size())
				bolPageBreak = false;
			else
				bolPageBreak = true;
			break;			
	 }%>
    <tr> 
      <td class="thinborder"><div align="center"><%=(iLoop+10)/10%></div></td>
      <td class="thinborder" height="25"><div align="center"><%=(String)vRetResult.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><div align="left"> 
          <%if(((String)vRetResult.elementAt(iLoop+5)) != null){%>
           <%=WI.getStrValue((String)vRetResult.elementAt(iLoop+5),"N/A") +"/"+ WI.getStrValue((String)vRetResult.elementAt(iLoop+6),"All")%>  
          <%}else{%>
           N/A 
          <%}%>
          </div></td>
      <td class="thinborder"><div align="left"> 
          <%if(((String)vRetResult.elementAt(iLoop+5)) != null){%>
          N/A 
          <%}else{%>
          <%=WI.getStrValue((String)vRetResult.elementAt(iLoop+6),"&nbsp;")%> 
          <%}%>
          </div></td>
      <td class="thinborder"><div align="left"><%=astrPOStatus[Integer.parseInt((String)vRetResult.elementAt(iLoop+7))]%></div></td>
      <td class="thinborder"><div align="center">
	      <%if(vRetResult.elementAt(iLoop+8) == null || ((String)vRetResult.elementAt(iLoop+8)).equals("0")){%>
          	&nbsp; 
          <%}else{%>
          	<%=(String)vRetResult.elementAt(iLoop+8)%> 
          <%}%>
	  </div></td>
      <td class="thinborder"><div align="right">
        <%if(vRetResult.elementAt(iLoop+9) == null || ((String)vRetResult.elementAt(iLoop+9)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vRetResult.elementAt(iLoop+9),true)%>
		<%}%>
      </div></td>
    </tr>
    <%  if(((String)vRetResult.elementAt(iLoop+8)) != null && ((String)vRetResult.elementAt(iLoop+8)).length() > 0)
			dTotalItems += Double.parseDouble((String)vRetResult.elementAt(iLoop+8));    
		
		if(((String)vRetResult.elementAt(iLoop+9)) != null && ((String)vRetResult.elementAt(iLoop+9)).length() > 0)
			dTotalAmount += Double.parseDouble((String)vRetResult.elementAt(iLoop+9));
	}%>
    <tr> 
      <td class="thinborder" height="25" colspan="7"><div align="left"></div>
        <div align="right"><strong>PAGE TOTAL :&nbsp; &nbsp;&nbsp;</strong></div></td>
      <td class="thinborder"><div align="center"><strong><%=CommonUtil.formatFloat(dTotalItems,false)%></strong></div></td>
      <td height="25" class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%></div></td>
    </tr>
    <%
	dGrandTotalItems += dTotalItems;
    if (iLoop >= vRetResult.size()){	
    %>
    <tr> 
      <td class="thinborder" height="25" colspan="7"><div align="left"></div>
        <div align="right"><strong>OVERALL SEARCH TOTAL :&nbsp; 
          &nbsp;&nbsp;</strong></div></td>
      <td class="thinborder"><div align="center">&nbsp;</div></td>
      <td height="25" class="thinborder"><div align="right"> 
          <strong><%=CommonUtil.formatFloat((String)vRetResult.elementAt(0),true)%></strong></div></td>
    </tr>
    <tr> 
      <td class="thinborder" colspan="9" ><div align="center"> *****************NOTHING 
          FOLLOWS *******************</div></td>
    </tr>
    <%}else{%>
    <tr> 
      <td class="thinborder" colspan="9" ><div align="center"> ************** 
          CONTINUED ON NEXT PAGE ****************</div></td>
    </tr>
    <%}%>
  </table>
  <%
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
