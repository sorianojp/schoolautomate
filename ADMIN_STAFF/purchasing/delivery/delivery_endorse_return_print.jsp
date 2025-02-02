<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,purchasing.Returns,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolFatalErr = true;
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-ENDORSEMENT"),"0"));
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
								"Admin/staff-PURCHASING-ENDORSEMENT-Search Returns","delivery_endorsement_return.jsp");
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
	
	Returns RET = new Returns();
	Vector vRetResult = null;
	String[] astrPOStatus = {"Disapproved","Approved","Pending"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
								"September","October","November","December"};
	
	int iSearch = 0;
	int iDefault = 0;
	boolean bolLooped = false;
	boolean bolSamePO = false;
	String strPrevRetIndex = null;
	String strPrevPO = null;
//	String strPrevColl = null;
//	String strPrevDept = null;
	
		vRetResult = RET.searchReturnEndorsement(dbOP,request);
%>
<form>
  <%if(vRetResult != null && vRetResult.size() > 3){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<%
			if(WI.fillTextValue("is_from_endorsed").length() > 0)
				strTemp = "LIST OF RETURNED ENDORSEMENTS";
			else
				strTemp = "LIST OF RETURNS TO SUPPLIER";
			
		%>
    <tr>			
      <td width="100%" height="25" colspan="2" class="thinborderTOPLEFTRIGHT">
				<div align="center"><strong><%=strTemp%></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="12%" height="25" align="center" class="thinborder"><strong>PO NO.</strong></td>
      <td width="11%" align="center" class="thinborder"><strong>RETURN DATE </strong></td>
      <td width="30%" align="center" class="thinborder"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%> / 
        DEPT</strong></td>
      <td width="24%" align="center" class="thinborder"><strong>SUPPLIER NAME</strong></td>
      <td width="23%" align="center" class="thinborder"><strong>REASON/REMARKS</strong></td>
    </tr>
    <%for(int i = 0;i < vRetResult.size();i+=12){
				bolSamePO = false;
		%>
    <tr>
      <%
				//if(bolLooped && strPrevPO.equals((String)vRetResult.elementAt(i+9))
				//	&& strPrevRetIndex.equals((String)vRetResult.elementAt(i+12))){
				//	strTemp = "";
				//	bolSamePO = true;
				//}else
					strTemp = (String)vRetResult.elementAt(i+2);
			%>
      <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+11);
			%>			
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%
				//if(bolSamePO){
				//	strTemp2 = "";
				//}else{
					if((String)vRetResult.elementAt(i + 3) == null || (String)vRetResult.elementAt(i + 4)== null){
						strTemp = " ";			
					}else{
						strTemp = " - ";
					}
					strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i + 3),"");
					strTemp2 += strTemp+ WI.getStrValue((String)vRetResult.elementAt(i + 4),"");
				//}				
			%>
      <td class="thinborder">&nbsp;<%=strTemp2%> </td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"0")%>&nbsp;</td>
      <%
				strTemp = (String)vRetResult.elementAt(i+7);
				strTemp2 = (String)vRetResult.elementAt(i+8);
				strTemp2 = WI.getStrValue(strTemp2,"");
				strTemp = WI.getStrValue(strTemp,"", "(" + strTemp2 + ")", "&nbsp;");
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
    </tr>
    <%bolLooped = true;
			strPrevPO = (String)vRetResult.elementAt(i + 1);			
			//strPrevColl = (String)vRetResult.elementAt(i + 10);
			//strPrevDept = (String)vRetResult.elementAt(i + 11);
		 }%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
  </table>
 <%}%>
 <!-- all hidden fields go here -->
<input type="hidden" name="proceedClicked" value=""> 
  <input type="hidden" name="printPage" value="">
	<input type="hidden" name="is_from_endorsed" value="<%=WI.fillTextValue("is_from_endorsed")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
