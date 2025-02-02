<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,
								hr.HRInfoLeave"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD{
	font-size: 11px;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function EditRecord(){

	document.form_.page_action.value="2";
	document.form_.submit();
}

function PrepareToEdit(strInfoIndex){
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value ="1";
	document.form_.page_action.value = "3";
	document.form_.submit();
}

function DeleteRecord(index){
	document.form_.page_action.value="0";
	document.form_.info_index.value = index;
	document.form_.prepareToEdit.value ="";
	document.form_.submit();
}

function CancelRecord(strEmpID){
	location = "./leave_apply.jsp?emp_id="+strEmpID+"&sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+"&semester="+document.form_.semester.value+"&my_home="+
	document.form_.my_home.value;
}
function FocusID() {
	document.form_.emp_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,dependent=yes');
	win.focus();
}

function ChangeLeave(){
	if(document.form_.cur_leave_text.value.toUpperCase().indexOf("MATERNITY") != -1){
		document.form_.cur_leave_text.value = document.form_.benefit_index[document.form_.benefit_index.selectedIndex].text;
		if(document.form_.cur_leave_text.value.toUpperCase().indexOf("MATERNITY") == -1){
			document.form_.submit();
		}
	}else{
		document.form_.cur_leave_text.value = document.form_.benefit_index[document.form_.benefit_index.selectedIndex].text;
		if(document.form_.cur_leave_text.value.toUpperCase().indexOf("MATERNITY") != -1){
			document.form_.submit();
		}
	}
}

function UpdateReqStatus(){
	

	if (document.form_.head_approved && 
		document.form_.vp_approved && 
		document.form_.pres_approved && 
		document.form_.leave_appl_status) {
		
		
		if (document.form_.head_approved.selectedIndex == 2 
			|| document.form_.vp_approved.selectedIndex == 2
			|| document.form_.pres_approved.selectedIndex == 2){	
				
			document.form_.leave_appl_status.selectedIndex = 4; // disapproved
			
		} else if ((document.form_.head_approved.selectedIndex == 3 
					|| document.form_.head_approved.selectedIndex == 1) && 
					(document.form_.vp_approved.selectedIndex == 0 
					|| document.form_.vp_approved.selectedIndex == 1) && 
					(document.form_.pres_approved.selectedIndex == 0 
					|| document.form_.pres_approved.selectedIndex == 1)){
			
			document.form_.leave_appl_status.selectedIndex = 3; // approved
	
	
			
		}else if (document.form_.head_approved.selectedIndex == 0){
			document.form_.leave_appl_status.selectedIndex = 0; // pending
		}else if (document.form_.vp_approved.selectedIndex == 3) {
			document.form_.leave_appl_status.selectedIndex = 1; // pending
		}else if (document.form_.pres_approved.selectedIndex == 3) {
			document.form_.leave_appl_status.selectedIndex = 2; // pending
		}
		
		if (document.form_.leave_appl_status.selectedIndex == 3){
			document.form_.is_final.checked =true;
			document.form_.actual_days.value = document.form_.days_applied.value;
			document.form_.actual_hours.value = document.form_.hours_applied.value;	
		}else{
			document.form_.is_final.checked =false;
			document.form_.actual_days.value = "";
			document.form_.actual_hours.value = "";
		}
	}
	
}

function ViewPrintDetails(strInfoIndex,strEmpID,strSYFrom,strSYTo,strSemester,strMyHome){
	var pgLoc = "./leave_apply_print.jsp?info_index="+strInfoIndex+"&emp_id="+escape(strEmpID)+
	"&sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+strSemester+"&format_date=6&my_home="+
	strMyHome;
	var win=window.open(pgLoc,"ViewPrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,dependent=yes');
	win.focus();

}

</script>

<%
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode != null && strSchCode.startsWith("AUF"))  {%>
	
	<jsp:forward page="./leave_apply_auf.jsp" />
		
<%  return;}
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
								"Admin/staff-PERSONNEL-Leave Application","leave_apply.jsp");

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
	if(bolMyHome){//for my home, allow applying leave.
		//if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		//else 
		//	iAccessLevel = 1;

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
boolean bolViewOnly = WI.fillTextValue("view_only").equals("1");



HRInfoLeave hrPx = new HRInfoLeave();

int iAction =  -1;

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}


if (strTemp.length()> 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
}

//if Emp ID is empty. I have to get it from session.getAttribute("encoding_in_progress_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	
strTemp = WI.getStrValue(strTemp);
 
vRetResult = hrPx.operateOnLeave(dbOP, request, 4);

String[] astrConvertAMPM={" AM"," PM"};
String[] astrCurrentStatus ={"Disapproved", "Approved", "Pending/On-process",
							 "Requires Approval of Vice-President", 
							 "Requires Approval of President"};

String strCurLeaveText = "";

%>
<body onLoad="window.print();">
  <%  if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0
		&& WI.fillTextValue("sy_from").length() != 0){ %>
		
<table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
<%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%> <br> <strong><%=strTemp%></strong><br> <font size="1"><%=strTemp2%></font><br> <font size="1"><%=strTemp3%></font><br> </td>
          </tr>
</table>		
		
   <% if (vRetResult != null && vRetResult.size() > 0) {%> 
        <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
          <tr> 
            <td height="21" colspan="7" align="center" bgcolor="#F2EDE6" class="thinborder"><strong>LIST 
              OF APPLIED LEAVES </strong></td>
          </tr>
          <tr> 
            <td width="13%" height="25" class="thinborder"><font size="1"><strong>&nbsp;Date 
              Filed</strong></font></td>
            <td width="18%" class="thinborder"><font size="1"><strong> &nbsp;Type 
              of Leave</strong></font></td>
            <td width="20%" class="thinborder"><font size="1"><strong> 
              Date Fr (Time) ::<br>
              Date To (Time)</strong></font></td>
            <td width="13%" align="center" class="thinborder"><font size="1"><strong>Days 
              (Hours) <br>
              Applied</strong></font></td>
            <td width="10%" class="thinborder"><font size="1"><strong>&nbsp; Status 
              </strong></font></td>
            <td width="16%" class="thinborder"><font size="1"><strong> &nbsp;Date 
              (Time) Return </strong></font></td>
            <td width="10%" class="thinborder"><font size="1"><strong>Actual Days 
              (Hours)</strong></font></td>
            <% if (!bolViewOnly) {%> 
            <%}%>
          </tr>
          <% for (int i =0 ; i < vRetResult.size() ; i+=46) {%>
          <tr> 
            <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+42),"Leave Without Pay")%></td>
            <%
				strTemp = (String)vRetResult.elementAt(i+10);
				if ((String)vRetResult.elementAt(i+11) != null){
					strTemp += "(" + (String)vRetResult.elementAt(i+11)  + ":" +
								(String)vRetResult.elementAt(i+12) +
								astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+13))] + 
								")";
				}
				
				strTemp += "<br>";
				
				if ((String)vRetResult.elementAt(i+14) != null) {
					strTemp +=" :: "  + (String)vRetResult.elementAt(i+14);
				}
				
									
				if ((String)vRetResult.elementAt(i+15) != null){
					if ((String)vRetResult.elementAt(i+14) == null){
						strTemp += (String)vRetResult.elementAt(i+10);
					}
					strTemp += "(" + (String)vRetResult.elementAt(i+15)  + ":" +
								(String)vRetResult.elementAt(i+16) +
								astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+17))] + 
								")";
				}
				
			%>
            <td class="thinborder">&nbsp;<%=strTemp%></td>
            <%
				strTemp ="";
				if (!((String)vRetResult.elementAt(i+22)).equals("0"))
					strTemp = (String)vRetResult.elementAt(i+22);
				if (!((String)vRetResult.elementAt(i+21)).equals("0"))
					strTemp += "(" + (String)vRetResult.elementAt(i+21) + ")";				
			%>
            <td class="thinborder">&nbsp;<%=strTemp%></td>
            <td class="thinborder">&nbsp;<strong><%=astrCurrentStatus[Integer.parseInt((String)vRetResult.elementAt(i+31))]%></strong></td>
            <%
				strTemp =WI.getStrValue((String)vRetResult.elementAt(i+25));
				if ((String)vRetResult.elementAt(i+32) != null)
					strTemp += "(" + (String)vRetResult.elementAt(i+32) + ":" 
						 + (String)vRetResult.elementAt(i+33) +  
						 astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+34))]					  
						 + ")";				
			%>
            <td class="thinborder">&nbsp;<%=strTemp%></td>
            <% strTemp ="";
			
				if (!((String)vRetResult.elementAt(i+26)).equals("0")) {
					strTemp =(String)vRetResult.elementAt(i+26);
				}
				if (!((String)vRetResult.elementAt(i+27)).equals("0")) {
					strTemp += "(" + (String)vRetResult.elementAt(i+27) + ")";
				}
			%>
            <td class="thinborder">&nbsp;<%=strTemp%></td>
            <% if (!bolViewOnly) {%> 			
            <%}%>
          </tr>
          <%} // end for loop %>
  </table>
		 <%} %>  
<% } %> 
</body>
</html>
<%
	dbOP.cleanUP();
%>
