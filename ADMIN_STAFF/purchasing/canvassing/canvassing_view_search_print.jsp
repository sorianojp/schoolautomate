<%@ page language="java" import="utility.*,purchasing.Canvassing,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);

	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
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
<body onLoad="window.print();">
<%
	
	DBOperation dbOP = null;	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-CANVASSING"),"0"));
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
								"Admin/staff-PURCHASING-CANVASSING-Canvassing View Search Print","canvassing_view_search_print.jsp");
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
								
	Canvassing CAN = new Canvassing();
	Vector vRetResult = null;		
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;	
	int iSearch = 0;
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	int iLoop = 1;
	boolean bolPageBreak = false;
	double dGrandTotalItems = 0d;
	double dTotalItems = 0d;
	double dTotalAmount = 0d;
	
	vRetResult = CAN.searchCanvass(dbOP,request);
	if(vRetResult == null)
		strErrMsg = CAN.getErrMsg();
	else
		iSearch = CAN.getSearchCount();
			
	if(vRetResult != null ){
	for(;iLoop < vRetResult.size();){
		dTotalItems = 0d;
		dTotalAmount = 0d;
%>
<form name="form_" method="post" action="./canvassing_view_search_print.jsp">
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
  <br>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td  height="25" colspan="9"  class="thinborder"><div align="center"><strong>LIST OF REQUESTED ITEMS / SUPPLIES FOR CANVASSING</strong></div></td>
	</tr>	  
	<tr> 
      <td colspan="9"  class="thinborder"><strong>TOTAL RESULT : <%=iSearch%></strong></td>
    </tr>
    <tr> 
	  <td  class="thinborder"><div align="center"><strong> COUNT NO.</strong></div></td>
      <td width="13%"  height="25"  class="thinborder"><div align="center"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%> 
          / DEPT</strong></div></td>
      <td width="15%"  class="thinborder"><div align="center"><strong>OFFICE</strong></div></td>
      <td width="18%"  class="thinborder"><div align="center"><strong>REQUISITION NO. / CANVASSING NO</strong></div></td>
      <td width="10%"  class="thinborder"><div align="center"><strong>DATE REQUESTED / CANVASSING DATE</strong></div></td>
      <td width="15%"  class="thinborder"><div align="center"><strong>REQUESTED BY</strong></div></td>
      <td width="7%"  class="thinborder"><div align="center"><strong>STATUS</strong></div></td>
      <td width="4%"  class="thinborder"><div align="center"><strong>TOTAL 
          ITEMS </strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>TOTAL 
          AMOUNT</strong></div></td>
    </tr>
	<% 
 	for(int iCount = 0; iCount <= iMaxStudPerPage; iLoop += 13,++iCount){
  		if (iCount >= iMaxStudPerPage || iLoop >= vRetResult.size()){
			if(iLoop >= vRetResult.size())
				bolPageBreak = false;
			else
				bolPageBreak = true;
			break;			
	 }%>
    <tr> 
	  <td  class="thinborder"><div align="center"><%=(iLoop+13)/13%></div></td>
      <td  class="thinborder" height="25"><div align="center"> 
          <%if(((String)vRetResult.elementAt(iLoop)) != null){%>
           <%=WI.getStrValue((String)vRetResult.elementAt(iLoop),"N/A") +"/"+ WI.getStrValue((String)vRetResult.elementAt(iLoop+1),"All")%> 
          <%}else{%>
          N/A<%}%>
        </div></td>
      <td  class="thinborder"><div align="center"> 
          <%if(((String)vRetResult.elementAt(iLoop)) != null){%>
          N/A 
          <%}else{%>
          <%=WI.getStrValue((String)vRetResult.elementAt(iLoop+1),"&nbsp;")%> 
          <%}%>
        </div></td>
      <td  class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(iLoop+2)%> /<br>
	   <%=vRetResult.elementAt(iLoop+11)%></div></td>
      <td  class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(iLoop+3)%> /<br>
	   <%=vRetResult.elementAt(iLoop+12)%></div></td>
      <td  class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(iLoop+4)%></div></td>
      <td  class="thinborder"><div align="center"><%=astrReqStatus[Integer.parseInt((String)vRetResult.elementAt(iLoop+5))]%></div></td>
      <td  class="thinborder"><div align="right"> 
		 <%if(vRetResult.elementAt(iLoop+6) == null || ((String)vRetResult.elementAt(iLoop+6)).equals("0")){%>
          &nbsp; 
          <%}else{%>
          <%=(String)vRetResult.elementAt(iLoop+6)%> 
          <%}%>
          </div></td>
      <td class="thinborder"><div align="right">	  
	  <%if(vRetResult.elementAt(iLoop+7) == null || ((String)vRetResult.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vRetResult.elementAt(iLoop+7),true)%>
		<%}%>
	  </div></td>
    </tr>
	<%  if(((String)vRetResult.elementAt(iLoop+6)) != null && ((String)vRetResult.elementAt(iLoop+6)).length() > 0)
			dTotalItems += Double.parseDouble((String)vRetResult.elementAt(iLoop+6));    
		
		if(((String)vRetResult.elementAt(iLoop+7)) != null && ((String)vRetResult.elementAt(iLoop+7)).length() > 0)
			dTotalAmount += Double.parseDouble((String)vRetResult.elementAt(iLoop+7));
	}%>    
    <tr> 
      <td  class="thinborder" height="25" colspan="7"><div align="left"></div>
        <div align="right"><strong>PAGE TOTAL :&nbsp; &nbsp;&nbsp;</strong></div></td>
      <td  class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalItems,false)%></strong></div></td>
      <td height="25" class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%></strong></div></td>
    </tr>
	<%	
	dGrandTotalItems += dTotalItems;
   if (iLoop >= vRetResult.size()){	
   %>
  <tr> 
      <td  class="thinborder" height="25" colspan="7"><div align="left"></div>
        <div align="right"><strong>OVERALL SEARCH TOTAL :&nbsp; 
          &nbsp;&nbsp;</strong></div></td>
      <td  class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dGrandTotalItems,false)%></strong></div></td>
      <td height="25" class="thinborder"><div align="right"><strong>
	  <%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(0),"0"),true)%></strong></div></td>
    </tr>
  <tr> 
    <td class="thinborder" colspan="9" ><div align="center"> *****************NOTHING FOLLOWS *******************</div></td>
  </tr>
   <%}else{%>    
  <tr> 
    <td class="thinborder" colspan="9" ><div align="center"> ************** CONTINUED ON NEXT PAGE ****************</div></td>
  </tr>
  <%}%>
</table><%
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
