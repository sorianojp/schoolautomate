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
<script language="JavaScript">
function UpdateBefefit(strUserIndex, strDependentIndex) {
	var loadPg = "./hr_personnel_dep_benefit.jsp?user="+strUserIndex+"dependent="+
		strDependentIndex;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == "1") {
		document.form_.hide_save.src = "../../../images/blank.gif";
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function viewList(table,indexname,colname,labelname){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+
		escape(labelname)+"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


</script>
<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoServiceRecord"%>
<%
	///added code for HR/companies.
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;String strTemp3 = null;
	String strImgFileExt = null;
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));	
	
	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;
		
	//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Service Record","hr_personnel_service_rec.jsp");
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
															"HR Management","PERSONNEL",request.getRemoteAddr(),
															"hr_personnel_service_rec.jsp");
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
	
	String[] astrPTFT = {"Part-Time", "Full-Time"};
	Vector vRetResult = null;
	Vector vEmpRec = null;
	Vector vTemp = null;
	boolean bolErrInEdit = false;//true if error while editing.
	
	HRInfoServiceRecord hrSR = new HRInfoServiceRecord();
	hr.OldServiceRecord oSR = new hr.OldServiceRecord();
	//collect information to display.
	
	strTemp = WI.fillTextValue("emp_id");
	if(strTemp.length() == 0)
		strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	strTemp = WI.getStrValue(strTemp);
	
	if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
		request.setAttribute("emp_id",strTemp);
	}
	if (strTemp.trim().length()> 0){
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
		if(vEmpRec == null || vEmpRec.size() == 0)
			strErrMsg = "Employee has no profile.";
	}
	
	Vector vLoad = null;
	
	if(strTemp.length() > 0 && vEmpRec != null) {
		vRetResult = hrSR.operateOnServiceRecord(dbOP, request, 4);
		
		vLoad = oSR.operateOnOldServiceRecord (dbOP, request, 6);
	//	if (vLoad == null) 
	//		strErrMsg = oSR.getErrMsg();
	}
	
	//System.out.println("mao ba ni?: "+WI.fillTextValue("show_name"));
%>

<body>

<% if (strErrMsg != null) {%>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> 
<%} if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="5">
  <%if(strSchCode.startsWith("AUF")){%>
   <tr>
  	<td height="40" align="center" valign="middle"><strong>SERVICE RECORD</strong></td>
  </tr>
  <%}%>
  <tr> 
    <td width="100%"> <table width="400" border="0" align="center">
        <tr> 
          <td width="100%" valign="middle"> 
            <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
            <%=WI.getStrValue(strTemp)%> <br> <br> 
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
            <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> 
            <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
			<%if (strSchCode.startsWith("AUF") || strSchCode.startsWith("UI")) {%> 
            <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%>
			<%}if (strSchCode.startsWith("AUF")) {%>
			<br><%=astrPTFT[Integer.parseInt((String)vEmpRec.elementAt(22))]%>, <%=(String)vEmpRec.elementAt(16)%>
			<%}%>
			</font>          </td>
        </tr>
      </table>
      <br>
  <%if (vRetResult != null && vRetResult.size() > 1) {%> 
      <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" class="thinborder">
        <tr> 
          <td height="30" colspan="8" class="thinborder"><div align="center"><strong>SERVICE 
              RECORD </strong></div></td>
        </tr>
        <tr> 
          <td width="12%" align="center" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>
          <td width="23%" align="center" class="thinborder"><font size="1"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%>/ 
            DEPT /OFFICE</strong></font></td>
          <td width="16%" align="center" class="thinborder"><strong><font size="1">INCLUSIVE 
            DATES</font></strong></td>            
		<%if (!strSchCode.startsWith("AUF")) {%>
			<td width="10%" align="center" class="thinborder"><font size="1"><strong>STATUS</strong></font></td>
			<td width="12%" align="center" class="thinborder"><font size="1"><strong>JOB RANK</strong></font></td>
          	<td width="12%" align="center" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
          	<td width="14%" align="center" class="thinborder"><strong><font size="1">BENEFITS</font></strong></td>
          	<td width="13%" align="center" class="thinborder"><font size="1"><strong>INCENTIVES</strong></font></td>
		 <%}%>
        </tr>
        <%
		  String[] astrConvertUnit = {"Per hr","Per unit","Per session"};
          String[] astrConvertSalPeriod = {"Daily","Weekly","Bi-monthly","Monthly"};
		  for (int i = 1; i < vRetResult.size(); i +=31){%>
        <tr> 
          <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 2)%>
		  	<%if(strSchCode.startsWith("AUF")){%>
				<br><%=astrPTFT[Integer.parseInt((String)vRetResult.elementAt(i + 28))]%>&nbsp;<%=(String)vRetResult.elementAt(i + 4)%>
			<%}%></font></td>
          <td class="thinborder"><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i + 6))%><%=WI.getStrValue((String)vRetResult.elementAt(i + 8),"<br>","","")%></font></td>
          <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i + 17)%> <%=WI.getStrValue((String)vRetResult.elementAt(i + 18)," - <br>",""," - present")%></font></div></td>               
		<%if (!strSchCode.startsWith("AUF")) {%>
			<td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 4)%></font></td>
			<td align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 12)%> <!--(<%=(String)vRetResult.elementAt(i + 13)%>)--></font></td>
          	<td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 29)%> </font></td>
          	<td class="thinborder"><font size="1"> <%=WI.getStrValue(vRetResult.elementAt(i + 15),"Not set")%></font></td>
          	<td class="thinborder"><font size="1"> <%=WI.getStrValue(vRetResult.elementAt(i + 16),"Not set")%></font></td>
		 <%}%>
        </tr>
        <% } // end for loop %>
      </table>
      <%}//end of if(vRetResult is not null) %> 
	  
<% if (vLoad!=null && vLoad.size()>0 && strSchCode.startsWith("UI")){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
    <td height="25" colspan="6" align="center" class="thinborder"><strong>FACULTY TEACHING LOAD DETAIL</strong></td>
  </tr>
  <tr>
    <td width="14%" height="25" class="thinborder"><div align="center"><strong>SCHOOL YEAR</strong></div></td>
    <td width="17%" class="thinborder"><div align="center"><strong>TERM</strong></div></td>
    <td width="10%" class="thinborder"><div align="center"><strong>TOTAL LOAD</strong></div></td>
    <td width="42%" class="thinborder"><div align="center"><strong>SUBJECTS</strong></div></td>
    <td width="10%" class="thinborder"><div align="center"><strong>SERVICE CREDIT</strong> </div></td>
    <td width="7%" class="thinborder"><strong>TOTAL CREDIT</strong> </td>
  </tr>
  <%	double dTotalCredit = 0d;
	String strServiceCredit = null;
	String [] astrSem = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};		
	for (int i = 0; i< vLoad.size(); i+=10){
	strServiceCredit = (String)vLoad.elementAt(i+9);
	dTotalCredit += Double.parseDouble(WI.getStrValue(strServiceCredit,"0"));
	strTemp = (String)vLoad.elementAt(i+1);%>
  <tr>
    <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vLoad.elementAt(i+2)%>&nbsp;-&nbsp;<%=(String)vLoad.elementAt(i+3)%></font></div></td>
    <td class="thinborder"><div align="center"><font size="1"> <%=astrSem[Integer.parseInt((String)vLoad.elementAt(i+4))]%></font></div></td>
    <td class="thinborder"><div align="center"><font size="1"><%=(String)vLoad.elementAt(i+5)%></font></div></td>
    <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vLoad.elementAt(i+7), (String)vLoad.elementAt(i+8))%>
          <% for (i += 10;i< vLoad.size(); i+=10){
      if ( ((String)vLoad.elementAt(i+1)).compareTo(strTemp) == 0 ){%>
      ,<%=WI.getStrValue((String)vLoad.elementAt(i+7), (String)vLoad.elementAt(i+8))%>
      <%}else{
      		i-=10;
	      break;
	    }
	 }%>
    </font></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(strServiceCredit,"-")%></td>
    <td class="thinborder">&nbsp;<%=CommonUtil.formatFloat(dTotalCredit,true)%></td>
  </tr>
  <%}%>
</table>
<% } // end if vLoad is ! null%>    </td>
  </tr>
  <%if(strSchCode.startsWith("AUF")){%>
  <tr>
  	<td>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
				<td height="20" width="50%"><font style="font-size:11px">Verified by:</font></td>
				<td width="50%"><font style="font-size:11px">Noted by:</font></td>
			</tr>
			<tr>
			  <td height="20">&nbsp;</td>
			  <td>&nbsp;</td>
		  </tr>
			<tr>
			  <td height="20"><font style="font-size:11px"><%=WI.fillTextValue("verified_by")%></font></td>
			  <td><font style="font-size:11px"><%=WI.fillTextValue("noted_by")%></font></td>
		  </tr>
		  <tr>
			  <td height="15">&nbsp;</td>
			  <td>&nbsp;</td>
		  </tr>
			<tr>
			  <td height="20"><font style="font-size:11px">Printed by: </font></td>
			  <td>&nbsp;</td>
		  </tr>
		  <tr>
			  <td height="20">&nbsp;</td>
			  <td>&nbsp;</td>
		  </tr>
			<tr>
			  <td height="20"><font style="font-size:11px"><%=request.getSession(false).getAttribute("first_name")%></font></td>
			  <td>&nbsp;</td>
		  </tr>
			<tr>
			  <td height="20"><font style="font-size:11px"><%=WI.formatDate(WI.getTodaysDate(1), 1)%></font></td>
			  <td>&nbsp;</td>
		  </tr>
		</table></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
  <%}%>
</table>
<script language="JavaScript"><!--
window.print();
--></script>
<%}//if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 1 -- most outer loop.%>
</body>
</html>
<%
dbOP.cleanUP();
%>
