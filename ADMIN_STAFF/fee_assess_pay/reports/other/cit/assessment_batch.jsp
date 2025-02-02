<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strStudInfoList = (String)request.getSession(false).getAttribute("stud_list");
	if(strStudInfoList == null || strStudInfoList.length() == 0) {%>
	<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold">Student List not found.</p>
	<%
		return; 
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<!--<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">-->
<style type="text/css">
<!--
body {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborder {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TABLE.thinborderALL {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
	<script language="javascript">
	function CallOnLoad() {
		document.all.processing.style.visibility='hidden';	
		document.bgColor = "#FFFFFF";
	}
	var strMaxPage = null;
	var objLabel   = null;
	function ShowProgress(pageCount, maxPage) {
		if(objLabel == null) {
			objLabel = document.getElementById("page_progress");
			strMaxPage = maxPage;
		}
		if(!objLabel)
			return;
		var strShowProgress = pageCount+" of "+strMaxPage;
		objLabel.innerHTML = strShowProgress;
	}
	</script>

<body topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" onLoad="CallOnLoad();window.print();" bgcolor="#DDDDDD">
<!-- Printing information. -->
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <!--<label id="page_progress"></label>-->
			<br>
			<img src="../../../../../Ajax/ajax-loader_small_black.gif">
			
			</font></p>
			
			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>
<%
	Vector vStudIDList = new Vector();
	String strPageURL  = "./assessment_one.jsp";
	if(WI.fillTextValue("pmt_schedule").equals("2"))
		strPageURL = "./assessment_one_mterm.jsp";
	
	strPageURL += "?sy_from="+WI.fillTextValue("sy_from")+"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")+
						"&pmt_schedule="+WI.fillTextValue("pmt_schedule")+"&grade_name="+WI.fillTextValue("grade_name")+"&font_size=11&batch_print=1";
	strPageURL += "&stud_id=";
	
	Vector vStudList = CommonUtil.convertCSVToVector(strStudInfoList, ",", true);
	
	
	boolean bolPageBreak = false;
	for(int i = 0; i < vStudList.size(); i++){
		Thread.sleep(200);
		if(i == (vStudList.size()-1))
			bolPageBreak = false;
		else
			bolPageBreak = true;
	%>
		<!--
		<script>
			ShowProgress('<%=i+1%>','<%=vStudList.size()%>');
		</script>	
		-->
		<jsp:include page="<%=strPageURL+(String)vStudList.elementAt(i)%>" />
	
	<%if(bolPageBreak){%>
		<DIV style="page-break-after:always" >&nbsp;</DIV>
	<%}%>
<%}%>
</body>
</html>
