<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,
								hr.HRInfoLeave"%>

<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;


	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Leave Record</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
	TD{
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;	
	}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

</style>
</head>
<script language="JavaScript">

function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}


</script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	boolean bolMyHome = false;

//add security hehol.

	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_personnel_education.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","LEAVE APPLICATION",request.getRemoteAddr(),
														"leave_apply.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		else 
			iAccessLevel = 1;

		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
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
Vector vRetResult = null;
Vector vEmpRec = null;
Vector vEditResult = null;
boolean bNoError = false;
boolean bolSetEdit = false;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

HRInfoLeave hrPx = new HRInfoLeave();

int iAction =  -1;

if (WI.fillTextValue("emp_id").length()> 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if (vEmpRec == null){
		strErrMsg = authentication.getErrMsg();
	}
}

vEditResult = hrPx.operateOnLeaveApplication(dbOP, request, 3);
if (vEditResult == null){
	strErrMsg = hrPx.getErrMsg();
}

//Vector vAllowedLeave = hrPx.getAllowedLeave(dbOP, request);
Vector vAllowedLeave = hrPx.getAvailableLeaveForSemNew(dbOP, request);

String strVice = null;
String strPres = null;
if(strSchCode.startsWith("TSUNEISHI")){
	strVice = "Requires Approval of Group Leader";
	strPres = "Requires Approval of Manager";
}else if(strSchCode.startsWith("LHS")){
	strVice = "Requires Approval of Manager";
	strPres = "Requires Approval of Country-Manager";
}else{
	strVice = "Requires Approval of Vice-President";
	strPres = "Requires Approval of President";
}

String strViceLabel = null;
String strPresLabel = null;
if(strSchCode.startsWith("TSUNEISHI")){
	strViceLabel = "Group Leader";
	strPresLabel = "Manager";
}else if(strSchCode.startsWith("LHS")){
	strViceLabel = "Manager";
	strPresLabel = "Country-Manager";
}else{
	strViceLabel = "Vice-President";
	strPresLabel = "President";
}

String[] astrConvertAMPM={" AM"," PM"};
String[] astrCurrentStatus ={"Disapproved", "Approved", "Pending/On-process",
							 strVice,  strPres};
String strSem = null;
%>
<body onLoad="window.print()">
<% if (strErrMsg != null && strErrMsg.length() > 0) { %>
<%=strErrMsg%>

<%}else if (vEmpRec !=null && vEmpRec.size() > 0 && vEditResult != null && vEditResult.size() > 0){ %>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr bgcolor="#FFFFFF">
    <td height="25" colspan="3" valign="middle">
	<div align="center"><font size="3"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
	  <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
	</div>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td height="25" colspan="3" align="center" valign="middle"><strong><font size="2">APPLICATION 
      FOR LEAVE</font></strong></td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td width="3%" valign="middle">&nbsp;</td>
    <td width="47%" height="25" valign="middle">NAME : <strong><%=WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4)%></strong></td>
    <%
	if((String)vEmpRec.elementAt(13) == null)
		strTemp = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
			 strTemp += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
    <td width="53%" valign="middle"><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%>/OFFICE : <strong><%=strTemp%> </strong></td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td valign="middle">&nbsp;</td>
    <td height="25" valign="middle"> POSITION : <strong><%=WI.getStrValue((String)vEmpRec.elementAt(15))%></strong></td>
    <td valign="middle"> STATUS OF EMPLOYMENT : <strong><%=WI.getStrValue((String)vEmpRec.elementAt(16))%></strong></td>
  </tr>
</table>
        
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25" colspan="3" valign="bottom" bgcolor="#FFFFFF"><div align="center">
        <hr width="95%" size="1" noshade>
        <strong><font size="2">DETAILS OF APPLICATION</font></strong></div></td>
  </tr>
  <tr> 
    <td height="25" colspan="2" valign="bottom" bgcolor="#FFFFFF"><strong>&nbsp; 
      AVAILABLE LEAVE CREDITS : </strong></td>
    <td width="46%" rowspan="2" bgcolor="#FFFFFF"><strong>DATE 
      OF APPLICATION :  <%=WI.getStrValue((String)vEditResult.elementAt(3))%><br>
      </strong><br> <strong>
      LEAVE APPLIED FOR : <br> <font size="3" color="#FF0000"> 
      <%
	  	strTemp = WI.getStrValue((String)vEditResult.elementAt(42),"Leave without Pay");
		if ( strTemp.toUpperCase().indexOf("LEAVE") == -1)
			strTemp = strTemp.toUpperCase() + " LEAVE";
	  %><%=strTemp%>
		  
	  </font>
	  </strong> </td>
  </tr>
  <tr> 
    <td width="3%" height="25">&nbsp;</td>
    <td width="49%" valign="top"> 
		<% if (vAllowedLeave != null && vAllowedLeave.size() > 0) {
		String[] astrSemester = {"Summer", "1st", "2nd","3rd","4th",""};
		%> 		
		<table width="80%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
        <% for(int i = 0 ; i < vAllowedLeave.size(); i+=15) {%>
        <tr> 
          <td width="70%" class="thinborder">&nbsp;&nbsp;<%=(String)vAllowedLeave.elementAt(i+4)%>
						<strong>
							<%
								strSem = WI.getStrValue((String)vAllowedLeave.elementAt(i+1),"5");
							%>
							<%=astrSemester[Integer.parseInt(strSem)]%>
							</strong>
							</td>
						<%
							strTemp = WI.getStrValue((String)vAllowedLeave.elementAt(i+5),"");
							if(strTemp.equals("5"))
								strTemp = "hour(s)";
							else
								strTemp = "day(s)";

							strTemp2 = (String)vAllowedLeave.elementAt(i+2);
							if(!strSchCode.startsWith("DEPED"))
								strTemp2 = CommonUtil.formatFloat(strTemp2, false);								
						%>							
          <td width="30%" height="20" align="right" class="thinborder">
					<%=strTemp2%> <%=strTemp%></strong></td>
        </tr>
        <%}%>
      </table>
      <%}else{%>
		<font size="2" color="#FF0000">NONE</font>
		<%}%> <br> </td>
  </tr>
</table>
        <%  // not required.. 
			if (false && WI.fillTextValue("cur_leave_text").toUpperCase().indexOf("MATERNITY") != -1) {  %> 
<table width="100%" border="0"  cellpadding="0" cellspacing="0">
  <tr> 
    <td>&nbsp;</td>
    <td colspan="3"><table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr> 
          <td width="24%" >&nbsp;Present No . of children :</td>
          <td width="74%" colspan="2"><strong> <%=dbOP.mapOneToOther("HR_INFO_SP_CHILD", "user_index",(String)vEmpRec.elementAt(0), "count(*)", 
			" and relation_index = 1 and is_del =0")%></strong></td>
        </tr>
        <tr> 
          <td >&nbsp;No. of Previous Deliveries: </td>
          <td colspan="2"><%=dbOP.mapOneToOther("HR_INFO_SP_CHILD", "user_index",(String)vEmpRec.elementAt(0), "count(*)", " and relation_index = 1 and is_del =0")%></td>
        </tr>
    </table></td>
  </tr>
  <tr> 
    <td width="2%">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;Expected date of delivery : <br> 
      <font color="#000000"> 
      &nbsp; 
      <%	if (vEditResult != null) 
		strTemp = WI.getStrValue((String)vRetResult.elementAt(7));
	else
		strTemp = WI.fillTextValue("expected_date");
%><%=strTemp%><a href="javascript:show_calendar('form_.expected_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"></a></font></td>
    <td width="65%">Start date of two(2) weeks pre-delivery 
      leave of absence :<br> 
      &nbsp; <%	if (vEditResult != null) 
		strTemp = WI.getStrValue((String)vRetResult.elementAt(8));
	else
		strTemp = WI.fillTextValue("pre_delivery");
%> <%=strTemp%>	</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td colspan="3">&nbsp;Number of days of maternity leave 
      : 
      <%
		if (vEditResult != null)
			strTemp = (String)vEditResult.elementAt(9);
		else
			strTemp = WI.fillTextValue("maternity_days");
	
		if (strTemp.length() == 0)
			strTemp = "60"; // default value for maternity leave		
	%><%=strTemp%></td>
  </tr>
</table>
        <%}%> 
      
<table width="100%" border="0"  cellpadding="2" cellspacing="0">
  <tr> 
    <td width="2%">&nbsp;</td>
    <td width="26%" >Inclusive Dates/Time of Leave ::</td>
    <td><strong><%=(String)vEditResult.elementAt(10)%>&nbsp;&nbsp; 
      <% strTemp =  WI.getStrValue((String)vEditResult.elementAt(11));
	if (strTemp.length() > 0) {
		strTemp = "(" + strTemp;
		if (WI.getStrValue((String)vEditResult.elementAt(12), "00").length() < 2){
			strTemp += ":0" + WI.getStrValue((String)vEditResult.elementAt(12), "00");
		}else{
			strTemp += ":" + WI.getStrValue((String)vEditResult.elementAt(12), "00");
		}			
		strTemp += astrConvertAMPM[Integer.parseInt(WI.getStrValue((String)vEditResult.elementAt(13),"0"))]
		 + ")";
	}
%>
      <%=strTemp%>
      <% strTemp = WI.getStrValue((String)vEditResult.elementAt(14));
	  if (strTemp.length() > 0) 
	  		strTemp = "&nbsp;&nbsp; - &nbsp;&nbsp;" + strTemp;
	  %>
      <%=strTemp%> 
      <%  strTemp =  WI.getStrValue((String)vEditResult.elementAt(15));
	if (strTemp.length() > 0) {
		strTemp = "(" + strTemp;
		if (WI.getStrValue((String)vEditResult.elementAt(16), "00").length() < 2){
			strTemp += ":0" + WI.getStrValue((String)vEditResult.elementAt(16), "00");
		}else{
			strTemp += ":" + WI.getStrValue((String)vEditResult.elementAt(16), "00");
		}

		strTemp += astrConvertAMPM[Integer.parseInt(WI.getStrValue((String)vEditResult.elementAt(17),"0"))]
		 + ")";
	}
%>
      <%=strTemp%></strong></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td colspan="2" valign="bottom" bgcolor="#FFFFFF" >No. of days/hrs applied 
      <strong>: 
      <%	
			strTemp = WI.getStrValue((String)vEditResult.elementAt(22),"0");
			if(((String)vEditResult.elementAt(46)).equals("1"))
				strTemp += " hour(s)";
			else
				strTemp += " day(s)";
	/*	
	if (strTemp.equals("0")) 
		strTemp = ""; 
	else
		strTemp += " day(s)";

	if (!WI.getStrValue((String)vEditResult.elementAt(21),"0").equals("0")){
		if (strTemp.length() != 0)
			strTemp += " / ";
		strTemp +=(String)vEditResult.elementAt(21) + " hour(s)";
	}
	*/
%>
      <%=strTemp%> </strong> </td>
  </tr>
</table>
        
<table width="100%" border="0"  cellpadding="2" cellspacing="0">
  <tr valign="bottom"> 
    <td width="2%" height="40">&nbsp;</td>
    <td width="18%" bgcolor="#FFFFFF" >Explanation/Reason : </td>
    <td width="76%" bgcolor="#FFFFFF" class="thinborderBottom" ><strong>&nbsp;<%=WI.getStrValue((String)vEditResult.elementAt(23))%></strong></td>
    <td width="4%" bgcolor="#FFFFFF" >&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="4" valign="bottom"><strong>Contact info while on 
      leave: </strong></td>
  </tr>
  <tr> 
    <td width="2%" height="24" valign="bottom">&nbsp;</td>
    <td width="8%" height="24" valign="bottom">Address : </td>
    <td height="24" colspan="2" valign="bottom" class="thinborderBottom"> &nbsp; <%=WI.getStrValue((String)vEditResult.elementAt(4))%></td>
    <td width="4%">&nbsp;</td>
  </tr>
  <tr> 
    <td width="2%" height="25" valign="bottom">&nbsp;</td>
    <td height="25" valign="bottom">Tel. No. : </td>
    <td height="25" colspan="2" valign="bottom" class="thinborderBottom">&nbsp;<%=WI.getStrValue((String)vEditResult.elementAt(5))%></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td width="2%" height="25" valign="bottom">&nbsp;</td>
    <td height="25" valign="bottom">Cell No. : </td>
    <td height="25" colspan="2" valign="bottom" class="thinborderBottom">&nbsp;<%=WI.getStrValue((String)vEditResult.elementAt(6))%></td>
    <td>&nbsp;</td>
  </tr>
</table>    
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td height="25" colspan="4" valign="bottom"><div align="center"> <strong><font size="2">DETAILS 
        OF ACTION ON APPLICATION</font></strong></div></td>
  </tr>
  <tr valign="bottom"> 
    <td width="43%" height="44">
		<%if(strSchCode.startsWith("TSUNEISHI")){%>
			Team Supervisor
		<%}else{%>
			<% if(bolIsSchool){%>
			 Dean/
			<%}%>							
				Dept Head
		<%}%> : _________________________________</td>
    <td height="44"> [ ] APPROVED&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[ ]&nbsp;DISAPPROVED&nbsp;</td>
    <td width="7%">Date : </td>
    <td width="17%" class="thinborderBottom"><%=WI.getStrValue((String)vEditResult.elementAt(35),"&nbsp;")%></td>
  </tr>
  <tr valign="bottom"> 
    <td height="29" valign="top"><div align="center"><font size="1">SIGNATURE 
        OVER PRINTED NAME</font></div></td>
    <td width="33%" height="29">&nbsp;</td>
    <td height="29">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr valign="bottom"> 
    <td height="30"> <%=strViceLabel%>
	: ___________________________</td>
    <td height="30">[ ] APPROVED&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[ ]&nbsp;DISAPPROVED&nbsp;</td>
    <td height="30">Date : </td>
    <td class="thinborderBottom"><%=WI.getStrValue((String)vEditResult.elementAt(36),"&nbsp;")%></td>
  </tr>
  <tr valign="bottom"> 
    <td height="29" valign="top"><div align="center"><font size="1">SIGNATURE 
        OVER PRINTED NAME</font></div></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr valign="bottom"> 
    <td height="25"> <p>
	   	<%=strPresLabel%>
	 : ___________________________</p></td>
    <td>[ ] APPROVED&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[ ]&nbsp;DISAPPROVED&nbsp;</td>
    <td>Date : </td>
    <td class="thinborderBottom"><%=WI.getStrValue((String)vEditResult.elementAt(37),"&nbsp;")%> </td>
  </tr>
  <tr> 
    <td height="29" valign="top"><div align="center"><font size="1">SIGNATURE 
        OVER PRINTED NAME</font></div></td>
    <td colspan="3">&nbsp;</td>
  </tr>
</table>
      <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr> 
          <td height="10" colspan="4">&nbsp;</td>
        </tr>
        <tr valign="bottom"> 
          <td width="17%" height="25">Subsitute Employee : </td>
<% if (vEditResult.elementAt(24) != null) 
		strTemp = dbOP.mapOneToOther("user_table", 
										"user_Index",(String)vEditResult.elementAt(24),
										"lname + ', ' + fname + ' ' mname" ,
										" and is_valid =1 and is_del = 0");
	else strTemp = "";
%>
          <td width="27%" height="25" class="thinborderBottom">&nbsp;<strong><%=strTemp%></strong></td>
          
    <td width="27%"><div align="right">Signature Substitute Employee: </div></td>
          
    <td width="29%">&nbsp;____________________________</td>
        </tr>
        <tr> 
          <td height="10" colspan="4">&nbsp;</td>
        </tr>
      </table>
      
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr valign="bottom"> 
    <td width="13%" height="25"> Request Status<font size="2">:</font> </td>
    <td width="36%" class="thinborderBottom"> &nbsp; 
      <% 
	strTemp = astrCurrentStatus[Integer.parseInt((String)vEditResult.elementAt(31))];
	if (strTemp.indexOf("pprove") == -1) 
		strTemp = "";
%> <strong><%=strTemp%></strong></td>
    <% 
		strTemp = WI.getStrValue((String)vEditResult.elementAt(38));
		if (strTemp.length() == 0) 
			strTemp = WI.getTodaysDate(6);
%>
    <td width="21%" height="25"><div align="right">Date of Request Status : </div></td>
    <td width="27%" class="thinborderBottom"><strong>&nbsp;<%=strTemp%></strong></td>
    <td width="3%">&nbsp;</td>
  </tr>
</table>
      
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr valign="bottom"> 
    <td width="9%" height="25">Remarks : </td>
    <td width="88%" height="25" class="thinborderBottom"><%=WI.getStrValue((String)vEditResult.elementAt(39),"&nbsp;")%></td>
    <td width="3%">&nbsp; </td>
  </tr>
  <tr> 
    <td height="20" colspan="3">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="5" cellspacing="0" class="thinborderALL">
        <tr class="thinborderALL"> 
          <% 
		if (WI.getStrValue((String)vEditResult.elementAt(32)).length() != 0) 
			strTemp = WI.getStrValue((String)vEditResult.elementAt(32)) + " : " +
					WI.getStrValue((String)vEditResult.elementAt(33)) + " " +
					astrConvertAMPM[Integer.parseInt(WI.getStrValue((String)vEditResult.elementAt(33),"0"))];
		else strTemp = "";
%>
          <td width="60%" height="20">DATE REPORTED FOR WORK: <strong><%=WI.getStrValue((String)vEditResult.elementAt(25))%> <%=WI.getStrValue(strTemp,"&nbsp;&nbsp;&nbsp; TIME : ","","") %> </strong></td>
		<%
			strTemp = WI.getStrValue((String)vEditResult.elementAt(26),"0");
			if(((String)vEditResult.elementAt(47)).equals("1"))
				strTemp += " hour(s)";
			else
				strTemp += " day(s)";
			/*
			if (strTemp.equals("0")) 
				strTemp = ""; 
			else
				strTemp += " day(s)";
		
			if (!WI.getStrValue((String)vEditResult.elementAt(27),"0").equals("0")){
				if (strTemp.length() != 0)
					strTemp += " / ";
			
				strTemp +=(String)vEditResult.elementAt(27) + " hour(s)";
			}
			*/
		%>
          <td width="40%" height="20">Actual No. Days/Hours Leave: <strong> <%=strTemp%></strong></td>
        </tr>
</table>
<% } %>
</body>
</html>
<%
	dbOP.cleanUP();
%>
