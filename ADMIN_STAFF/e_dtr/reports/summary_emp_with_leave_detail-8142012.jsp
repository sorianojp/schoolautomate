<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Leave Detail</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrintPage(){
	document.getElementById('footer').deleteRow(0);
	document.getElementById('footer').deleteRow(0);
	window.print();
}

function updateLeave(leave_date,strEmpIndex,dateFrom){
	if(leave_date.length > 0){		
		document.form_.leave_date.value = leave_date;		
		document.form_.update_record.value = '1';
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.submit();		
	}
}

function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.form_.submit();
		window.opener.focus();
	}
}


</script>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size:11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<body bgcolor="#FFFFFF" onUnload="javascript:ReloadParentWnd();">

<%@ page language="java" import="utility.*,java.util.Vector,eDTR.RestDays,payroll.PRSalary,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strImgFileExt = null;
	String strTemp2 = null;
	String strTemp3  = null;
//add security here.
	try
	{
	
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-Summary Emp With Absent (Detail)",
								"summary_emp_with_absent_detail.jsp");

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
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"summary_emp_with_absent_detail.jsp");	
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

//////////////// get parameter details \\\\\\\\\\\\\\\\|

String strSQLCutOffFrom = null;
String strEmpIndex = null;
String strEmpId = null;
String strDateFrom = WI.fillTextValue("date_fr");
String strLeaveDate = WI.fillTextValue("leave_date");
String strIsCredited = WI.getStrValue(WI.fillTextValue("is_credited"),"0");
boolean bolIsCredited = false;
	if(strIsCredited.equals("1"))
		bolIsCredited = true;

	try{
		strEmpId = WI.fillTextValue("emp_id");
		strTemp = strEmpId;
		strEmpIndex =  dbOP.mapUIDToUIndex(strEmpId);
		if (strEmpIndex == null) {
		  strErrMsg = "Employee ID :" + WI.fillTextValue("emp_id") + " does not exist.";
		  return;
		}		
		strSQLCutOffFrom = ConversionTable.convertTOSQLDateFormat(strDateFrom);		
	}catch(Exception exp){
		exp.printStackTrace();
		strErrMsg = "Error in getting parameter details";		
	}
/////////////// end of getting paramenter Details \\\\\|


enrollment.Authentication authentication = new enrollment.Authentication();
/*
RestDays rd= new RestDays(request);

Vector vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
if(vEmpRec == null || vEmpRec.size() ==0)
	strErrMsg = authentication.getErrMsg();


vRetResult = rd.viewEmpAbsenceDetail(dbOP,request);
if (vRetResult == null || vRetResult.size() == 0) 
	strErrMsg = rd.getErrMsg();
	
*/	


Vector vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
if(vEmpRec == null || vEmpRec.size() ==0)
	strErrMsg = authentication.getErrMsg();

PRSalary prSalary= new PRSalary();
double dTotalNumberOfLeaveDays = 0d;
Vector vLeaveDetail = null;
try{	
	if(!bolIsCredited){ //show not credited leave

		strDateFrom = WI.fillTextValue("date_fr");
		strLeaveDate = WI.fillTextValue("leave_date");
		//if delete is click
		//if(WI.fillTextValue("is_delete").length() > 0 && WI.fillTextValue("is_delete").equals("1") && WI.fillTextValue("leave_date").length() > 0 ){
		if(strLeaveDate != null && strLeaveDate.length() > 0 ){		
			strLeaveDate = ConversionTable.convertTOSQLDateFormat(strLeaveDate);
			if(!prSalary.updateLeaveCreditStatus(dbOP, strEmpIndex,null,strLeaveDate, 2)) 
				strErrMsg = prSalary.getErrMsg();
		}	
		vLeaveDetail =(Vector)prSalary.getApprovedLeavesButNotYetPaid(dbOP,strEmpIndex,strSQLCutOffFrom);
		if (vLeaveDetail == null || vLeaveDetail.size() == 0) 
			strErrMsg = prSalary.getErrMsg();
		else{		
				dTotalNumberOfLeaveDays = ((Double)vLeaveDetail.elementAt(0)).doubleValue();
				vRetResult = (Vector)vLeaveDetail.elementAt(1); //leave date and equivalent day					
		}	
	}else{ //show credited leave
		String strSalIndex = WI.fillTextValue("sal_index");
		vLeaveDetail =(Vector)prSalary.getCreditedLeaveOnSalary(dbOP,strEmpIndex,strSalIndex);
		if (vLeaveDetail == null || vLeaveDetail.size() == 0) 
			strErrMsg = prSalary.getErrMsg();
		else{		
				dTotalNumberOfLeaveDays = ((Double)vLeaveDetail.elementAt(0)).doubleValue();
				vRetResult = (Vector)vLeaveDetail.elementAt(1); //leave date and equivalent day					
		}	
	
	
	}
	
}catch(Exception ex){
	ex.printStackTrace();
	System.out.print("\n\nError");
}	

%>
<%=WI.getStrValue(strErrMsg)%>
<% if (vRetResult !=null && vRetResult.size()>0 && vEmpRec != null && vEmpRec.size() > 0){%>
  <form action="" name="form_" >
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
        <td><div align="center">
            <p><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
                <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></p>
          <table width="400" border="0" align="center">
              <tr bgcolor="#FFFFFF">
                <td width="100%" valign="middle"><%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
                    <%=WI.getStrValue(strTemp)%> <br>
                    <br>
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
%>
                    <br>
                    <strong><%=WI.getStrValue(strTemp)%></strong><br>
                    <font size="1"><%=WI.getStrValue(strTemp2)%></font><br>
                    <%=WI.getStrValue(strTemp3)%><br>
                    <br>
                    <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
                  </font> </td>
              </tr>
            </table>
          <br>
        </div></td>
      </tr>
    </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
    <tr> 
      <td width="40%" height="25" bgcolor="#EBEBEB" class="thinborder"><div align="center"><strong>DATE 
          OF LEAVE</strong></div></td>
      <td width="20%" height="25" bgcolor="#EBEBEB" class="thinborder"><div align="center"><strong>&nbsp;</strong></div></td>
	  <%if(!bolIsCredited)
	  		strTemp = "Option";
		else
			strTemp = "Remark"; %>
		  <td width="40%" height="25" bgcolor="#EBEBEB" class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>
     
	</tr>
    <% for (int i = 0; i < vRetResult.size() ; i+=3){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=WI.formatDate((Date)vRetResult.elementAt(i),10)%></td>
      <td class="thinborder">&nbsp;<%= ((Double)vRetResult.elementAt(i+1)).doubleValue()%>&nbsp; day</td>
	  <td class="thinborder">&nbsp;
	   <%if(!bolIsCredited){ %>
			<a href="javascript:updateLeave('<%=WI.formatDate((Date)vRetResult.elementAt(i),1)%>','<%=strEmpId%>','<%=strDateFrom%>')" /> <img src="../../../images/delete.gif" />  </a>Exlude to payroll
		<%}else{%>
			Already credited
		<%}%>
      </td>
    </tr>
    <%} // end for loop%>
    <tr> 
      <td height="25" colspan="3" class="thinborder"><strong>TOTAL DAYS OF LEAVE(S) 
        : <%=dTotalNumberOfLeaveDays%></strong></td>
    </tr>
  </table>
  <!--
  <table width="100%" border="0" id="footer">
    <tr> 
      <td height="15">&nbsp; </td>
    </tr>
    <tr>
      <td><div align="center"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>print 
          employee absence detail </div></td>
    </tr>
  </table>
  -->
    <%}%>
    <input type="hidden" name="date_fr" value="<%=WI.fillTextValue("date_fr")%>">
	<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
	<input type="hidden" name="is_delete" value="0">
	<input type="hidden" name="leave_date" value="">
	
	  <!-- this is used to reload parent if Close window is not clicked. -->
	  <input type="hidden" name="close_wnd_called" value="0">
	  <input type="hidden" name="donot_call_close_wnd" value="<%=WI.getStrValue(WI.fillTextValue("donot_call_close_wnd"),"")%>">
	  <!-- this is very important - onUnload do not call close window -->
	  <input type="hidden" name="update_record" value="<%=WI.fillTextValue("update_record")%>">
	
	
</form>
</body>
</html>
<% dbOP.cleanUP(); %>