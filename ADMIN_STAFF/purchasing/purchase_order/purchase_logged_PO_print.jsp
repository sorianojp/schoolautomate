<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Approved PO</title>
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
								"Admin/staff-PURCHASING-PURCHASE ORDER-Print Approved PO","purchase_approved_requests_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}
	
	Requisition REQ = new Requisition();
	PO PO = new PO();
	Vector vRetResult = null;
	Vector vPOItems  = null;
	int iColSpan = 0;
	int iDefault = 0;
	int iSearch = 0;
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	int i = 0;
	boolean bolPageBreak = false;
	double dGrandTotalItems = 0d;
	double dTotalItems = 0d;
	double dTotalAmount = 0d;
	String strTemp  = null;
	boolean bolLooped = false;
	
	vRetResult = PO.searchLoggedPO(dbOP,request);
	if(vRetResult == null)
		strErrMsg = PO.getErrMsg();
	else
		iSearch = PO.getSearchCount();
	
	if(vRetResult != null ){
	for(;i < vRetResult.size();){
		dTotalItems = 0d;
		dTotalAmount = 0d;
		bolLooped = false;	
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
      <td height="26" colspan="3"><div align="center"><strong>LIST OF LOGGED PURCHASE 
          ORDERS</strong></div></td>
    </tr>
	<%if((WI.fillTextValue("c_index")).equals("0")){%>
    <tr> 
      <td width="2%" height="26">&nbsp;</td>
      <td width="18%"><font size="1">Office</font></td>
      <td width="80%"><strong><font size="1"> 
        <%if(WI.fillTextValue("d_index").equals("0")){%>
        All 
        <%}else{%>
        <%=dbOP.mapOneToOther("DEPARTMENT","D_INDEX",WI.fillTextValue("d_index"),"D_NAME","")%> 
        <%}%>
        </font></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</font></td>
      <td><strong><font size="1"><%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",WI.fillTextValue("c_index"),"C_NAME",""),"All")+"/"+WI.getStrValue(dbOP.mapOneToOther("DEPARTMENT","D_INDEX",WI.fillTextValue("d_index"),"D_NAME",""),"All")%></font></strong></td>
    </tr>
    <%}%>
  </table>
  <br>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="7%" height="25" class="thinborder"><div align="center"><font size="1"><strong>PO 
          DATE</strong></font></div></td>
      <td width="12%" class="thinborder"><strong>PO NO.</strong></td>
      <td width="12%" class="thinborder"><strong>SUPPLIER</strong></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>REQUESTING 
          DEPARTMENT </strong></font></div></td>
      <td width="36%" class="thinborder"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>UNIT 
          PRICE</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong><strong>TOTAL 
          PRICE</strong></strong></font></div></td>
    </tr>
    <% 
	for(int iCount = 0;i < vRetResult.size();i+=8, iCount++){
		vPOItems = (Vector) vRetResult.elementAt(i + 7);
		if (iCount >= iMaxStudPerPage || i >= vRetResult.size()){
		if(i >= vRetResult.size())
			bolPageBreak = false;
		else
			bolPageBreak = true;
		break;		
	}%>
    <tr> 
      <td height="25" valign="top" class="thinborder"><div align="right"><font size="1"> 
          <%if (bolLooped && ((String)vRetResult.elementAt(i + 2)).equals((String)vRetResult.elementAt(i-6))){%>
          &nbsp; 
          <%}else{%>
          <%=(String)vRetResult.elementAt(i+2)%> 
          <%}%>
          </font></div></td>
      <td valign="top" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td valign="top" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+6)%></font></td>
      <td valign="top" class="thinborder"> <div align="left"> <font size="1"> 
          <%if(((String)vRetResult.elementAt(i+4)) != null){%>
          <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"") +"/"+ WI.getStrValue((String)vRetResult.elementAt(i+5),"All")%> 
          <%}else{%>
          <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%> 
          <%}%>
          </font></div></td>
      <td colspan="3" valign="top" class="thinborder"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <%if (vPOItems!= null && vPOItems.size() > 0){
		   		for (int j = 0;j < vPOItems.size();j+=7){
		   %>
          <tr> 
            <td width="63%"> <div align="left"><font size="1">
			 <%=WI.getStrValue((String) vPOItems.elementAt(j+1),"")%> 
                <%=WI.getStrValue((String) vPOItems.elementAt(j+4),"")%>- <%=WI.getStrValue((String) vPOItems.elementAt(j+5),"")%>&nbsp;<%=WI.getStrValue((String) vPOItems.elementAt(j+6),"")%> 
                </font> </div></td>
            <td width="20%"><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat((String) vPOItems.elementAt(j+2),true),"")%>&nbsp;</font></div></td>
            <td width="17%"><div align="right"><font size="1"><%=WI.getStrValue((String) vPOItems.elementAt(j+3),"")%>&nbsp;</font></div></td>
          </tr>
          <%}
		  }
		  %>
        </table></td>      
    </tr>
    <%
		bolLooped = true;
	}%>
	  <%if (i >= vRetResult.size()){	
    %>
    <tr> 
      <td class="thinborder" colspan="8" ><div align="center"> *****************NOTHING 
          FOLLOWS *******************</div></td>
    </tr>
    <%}else{%>
    <tr> 
      <td class="thinborder" colspan="8" ><div align="center"> ************** 
          CONTINUED ON NEXT PAGE ****************</div></td>
    </tr>
    <%}%>
  </table>
  <%
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }
	}
	%>
</body>
</html>
<%
dbOP.cleanUP();
%>
