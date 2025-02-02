<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function CloseWindow(){
	window.opener.document.dtr_op.show_history.checked = false;
	self.close();
	opener.focus();
}
</script>
<body bgcolor="#D2AE72" onUnload="CloseWindow()" >
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.WorkingHour" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strPrepareToEdit = null;

	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","set_working_history.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 0;
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
			iAccessLevel  = 2;
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"set_working_history.jsp");
}

if (strTemp == null) 
	strTemp = "";
//														
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	WorkingHour whPersonal = new WorkingHour();
	Vector vRetResult = null;
	String[] astrConvertWeekDay= {"SUNDAY","MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"};	
	String[] astrConverAMPM = {"AM","PM"};
	
strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}	


%>	
<form action="./set_working.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" ><strong>:::: 
      WORKING HOURS MGMT - SET WORKING HOURS PAGE ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25"><strong><font size=2><%=WI.getStrValue(strErrMsg)%>
<% if(!bolMyHome) {%>
	  &nbsp;<a href="javascript:CloseWindow()"><img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a>
<%}%>	  
	  
	  </font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<% if (!bolMyHome) {%>
    <tr valign="top"> 
      <td width="2%" height="30">&nbsp;</td>
      <td width="14%" height="30">Employee ID </td>
      <td width="84%" height="30"><input name="emp_id" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);" value="<%=WI.fillTextValue("emp_id")%>" size="16">      </td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>      </td>
    </tr>
<%}%>	
  </table>
<% 

if (strTemp.length() > 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
  vRetResult = authentication.operateOnBasicInfo(dbOP,request,"0");
	if (vRetResult !=null){
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="15">&nbsp;</td>
      <td width="37%" height="15" colspan="2"><font size="1">Employee Name</font></td>
      <td width="61%" height="15"><font size="1">Employee Status</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <% strTemp = WI.formatName((String)vRetResult.elementAt(1), (String)vRetResult.elementAt(2),
									(String)vRetResult.elementAt(3),1); %>
      <td colspan="2" valign="top"><font size="1"><strong><%=WI.getStrValue(strTemp)%></strong></font></td>
      <% strTemp = (String)vRetResult.elementAt(16);%>
      <td valign="top"><font size="1"><strong><%=WI.getStrValue(strTemp)%></strong></font></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td height="15" colspan="2"><font size="1">Position</font></td>
      <td height="15"><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <% strTemp = (String)vRetResult.elementAt(15);%>
      <td colspan="2" valign="top"><font size="1"><strong><%=WI.getStrValue(strTemp)%></strong></font></td>
      <%
				if((String)vRetResult.elementAt(13) == null)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(14));
			else
			{	
				strTemp =WI.getStrValue((String)vRetResult.elementAt(13));
				if((String)vRetResult.elementAt(14) != null)
					strTemp += "/" + WI.getStrValue((String)vRetResult.elementAt(14));
			}
%>
      <td valign="top"><font size="1"><strong><%=WI.getStrValue(strTemp)%></strong></font></td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr bgcolor="#B9B292"> 
      <td height="25" colspan="9" align="center" bgcolor="#B9B292">LIST OF 
        EXISTING WORKING HOURS HISTORY FOR ID : <%=WI.fillTextValue("emp_id")%> </td>
    </tr>
    <tr> 
      <td height="25" colspan="9">
	  <table width="95%" border="0" align="center" cellpadding="2" cellspacing="0" class="thinborder">
   <% vRetResult = whPersonal.getEmployeeWorkingHours(dbOP,request,true, true);
	if (vRetResult == null) {  %>
          <tr> 
            <td colspan=3 align="center" class="thinborder"><font size=2><strong> 
              No Record of Employee Working Hours History</strong></font></td>
          </tr>
          <% } // end if ( vRetResult == null)
		  else{ // else if (vRetResult == null)%>
          <tr> 
            <td width="26%" class="thinborder"><strong>EFFECTIVE DATES</strong></td>
            <td width="22%" height="25" align="center" class="thinborder"><strong>WEEK 
              DAY</strong></td>
            <td width="52%" class="thinborder"><strong>TIME / HOURS</strong></td>
          </tr>
          <% if(vRetResult.size() == 2 && ((String)vRetResult.elementAt(0)).equals("-1")){
		  vRetResult.removeElementAt(0);//do not enter in next loop. %>
          <tr> 
            <td width="26%" height="25" class="thinborder">&nbsp;</td>
            <td colspan="2" align="center" class="thinborder">
              <strong>NON-EDTR EMPLOYEE</strong></td>
          </tr>
          <%}else {//end if (vRetResult.size() == 2 && ((String)vRetResult.elementAt(0)).compareTo("-1") == 0)
		  for (int i = 0; i < vRetResult.size(); i+=42){
		  
//		  	System.out.println( " 14 : " + (String)vRetResult.elementAt(i+14));
//		  	System.out.println( " i : " + (String)vRetResult.elementAt(i));
		  %>
          <tr> 
            <%	strTemp = (String)vRetResult.elementAt(i+14);
			
		if(strTemp.equals("1")){ // flex time
			
			strTemp2 =(String)vRetResult.elementAt(i+1);
		
			if (strTemp2 == null) 
				strTemp2 = "N/A Weekday";
			else 
				strTemp2 = astrConvertWeekDay[Integer.parseInt(strTemp2)];

			strTemp = (String)vRetResult.elementAt(i+15);
%>
            <td bgcolor="#FFFFFF"  class="thinborder">&nbsp;
				<%=WI.getStrValue((String)vRetResult.elementAt(i+33),"**") + 
				WI.getStrValue((String)vRetResult.elementAt(i+34)," - ",""," - present")%></td>
            <td height="25" bgcolor="#FFFFFF" class="thinborder"><%=strTemp2%></td>
						<%
				strTemp2 = (String)vRetResult.elementAt(i+19) +  ":"  + 
				 CommonUtil.formatMinute((String)vRetResult.elementAt(i+20)) +
				 " " +(String)vRetResult.elementAt(i+21) + " - " + (String)vRetResult.elementAt(i+22)  +
		  		":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+23))  + " " + 
				  (String)vRetResult.elementAt(i+24);						
						%>
            <td bgcolor="#FFFFFF" class="thinborder"><strong>
					<%=WI.getStrValue(strTemp2)%> (<%=WI.getStrValue(strTemp)%> hours flex time)</strong></td>
          </tr>
          <%} else { // else  
		  
		  %>
          <tr> 
      <% strTemp = (String)vRetResult.elementAt(i);
			
		if (strTemp != null){ // default working hour
			strTemp = astrConvertWeekDay[Integer.parseInt((String)vRetResult.elementAt(i+18))]; 
	   %>
            <td  class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+33),"**") + 
					WI.getStrValue((String)vRetResult.elementAt(i+34)," - ",""," - ***")%></td>
            <td height="25"  class="thinborder"><%=WI.getStrValue(strTemp)%></td>
            <% strTemp2 = (String)vRetResult.elementAt(i+19) +  ":"  + 
			 CommonUtil.formatMinute((String)vRetResult.elementAt(i+20)) +
		 " " +(String)vRetResult.elementAt(i+21) + " - " + (String)vRetResult.elementAt(i+22)  +
		  ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+23))  + " " + 
		  (String)vRetResult.elementAt(i+24);

			if ((String)vRetResult.elementAt(i+25) != null) 
				strTemp2 +=  " / " + (String)vRetResult.elementAt(i+25) + 
				":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+26)) +
			  " " + (String)vRetResult.elementAt(i+27) + 
				" - " +  (String)vRetResult.elementAt(i+28) + 
				":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+29)) +  
				" " + (String)vRetResult.elementAt(i+30);
			
			//" / " + (String)vRetResult.elementAt(i+25) + 
		  //":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+26)) +
		  //" " + (String)vRetResult.elementAt(i+27) + " - " + (String)vRetResult.elementAt(i+28) 
		  //+ ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+29)) +  " " + 
		  //(String)vRetResult.elementAt(i+30);


		if (((String)vRetResult.elementAt(i+32)).equals("1"))
			strTemp2 +="(next day)";
%>
            <td class="thinborder"><strong><%=WI.getStrValue(strTemp2,"&nbsp;")%></strong></td>
          </tr>
          <% }else{ %>
          <tr> 
						<%
						strTemp = (String)vRetResult.elementAt(i+1);
						if (strTemp == null){
							strTemp = "N/A Weekday";
							strTemp2 = (String)vRetResult.elementAt(i+36);
						} else {
							strTemp = astrConvertWeekDay[Integer.parseInt(strTemp)];
							strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+33),"**") +
												 WI.getStrValue((String)vRetResult.elementAt(i+34)," - ",""," - ***");
						}
						%>
            <td class="thinborder"><%=WI.getStrValue(strTemp2)%></td>
            <td height="25" class="thinborder"><%=strTemp%></td>
						<%
						 strTemp2 = (String)vRetResult.elementAt(i+2) +  ":"  + 
						 CommonUtil.formatMinute((String)vRetResult.elementAt(i+3)) +
						 " " +(String)vRetResult.elementAt(i+4) + " - " + (String)vRetResult.elementAt(i+5) +
						 ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+6)) + " " + 
						 (String)vRetResult.elementAt(i+7);
					
						if ((String)vRetResult.elementAt(i+8) !=null){
						strTemp2 += " / " + (String)vRetResult.elementAt(i+8) + ":"  + 
							CommonUtil.formatMinute((String)vRetResult.elementAt(i+9)) +
							" " + (String)vRetResult.elementAt(i+10) + " - " + 
							(String)vRetResult.elementAt(i+11) +  ":"  + 
							CommonUtil.formatMinute((String)vRetResult.elementAt(i+12)) +  " " + 
							(String)vRetResult.elementAt(i+13);
								 
						if (((String)vRetResult.elementAt(i+32)).equals("1"))
							strTemp2 +=" (next day)";
						}						
						%>
            <td class="thinborder"><strong><%=WI.getStrValue(strTemp2,"")%></strong></td>
          </tr>
          <%}// end else
    }
   } // end for loop
  } // end if
} // else if (vRetResult == null)
} %>
        </table></td>
    </tr>
    <tr > 
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<%}%>
<!-- here lies the great mysteries of and future-->

<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="">
<input type="hidden" name="prepareToEdit" value="">
<input type="hidden" name="iStatus" value="">
<input type="hidden" name="adhoc_only" value="<%=WI.fillTextValue("adhoc_only")%>">

<!-- for non-EDTR set user_index if called for nonEDTR remove info-->
<input type="hidden" name="non_EDTR">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
